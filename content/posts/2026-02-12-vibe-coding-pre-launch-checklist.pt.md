---
title: "O que fazer antes de colocar um app vibecodado no ar"
date: 2026-02-12
description: "Checklist prático de segurança, performance e operações para quem usou vibe coding e quer ir pra produção sem desastre. Por uma dev com 9+ anos de experiência."
tags: ["vibe-coding", "segurança", "deploy", "checklist", "produção", "AI"]
categories: ["Opinião", "Engenharia"]
slug: "vibe-coding-pre-launch-checklist"
keywords:
  - vibe coding segurança
  - checklist deploy produção
  - app vibecodado produção
  - segurança código AI
  - pre-launch checklist developers
draft: false
---

Vibe coding virou febre. Você descreve o que quer, o modelo gera o app, e em meia hora tem algo rodando no localhost. É genuinamente impressionante. Eu uso AI no meu fluxo de trabalho todos os dias — pra gerar boilerplate, revisar PRs, acelerar tarefas repetitivas.

Mas toda semana eu vejo alguém no Twitter/X postando orgulhoso: *"Fiz meu SaaS inteiro com vibe coding em um fim de semana! Já tá no ar!"*

E toda semana alguém descobre, do pior jeito possível, que **funcionar no localhost não é a mesma coisa que estar pronto pra produção**.

Este artigo é o checklist que eu gostaria que essas pessoas lessem *antes* do deploy. Não é teoria — é o que 9+ anos de backend em sistemas financeiros me ensinaram sobre o que dá errado quando você pula etapas.

## O problema real

O primeiro deploy é talvez 10-20% do trabalho real. O que acontece quando o resto é ignorado?

- **Banco de dados aberto**: RLS desabilitado no Supabase = qualquer usuário acessa dados de qualquer outro usuário. Já vi isso em produção com dados financeiros reais.
- **API keys no frontend**: O modelo gerou o código, você fez deploy, e sua chave da OpenAI tá no bundle JavaScript. Alguém acha, gasta $2.000 no seu cartão em uma noite.
- **Zero rate limiting**: Um bot descobre seu endpoint público e faz 100.000 requests por minuto. Sua fatura da Vercel/AWS vem com surpresa.
- **Sem validação server-side**: O frontend valida, mas qualquer pessoa com curl bypassa tudo e injeta o que quiser.

Nenhum desses cenários é hipotético. Todos acontecem *toda semana* com apps vibecodados.

## Checklist de Segurança

Esse é o bloco não-negociável. Não importa se é um side project, um MVP, ou "só um teste" — se tem usuários reais, tem responsabilidade real.

### Database

```sql
-- Verificar se RLS está habilitado em TODAS as tabelas (Supabase/Postgres)
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

- **RLS habilitado em todas as tabelas** — essa é a falha #1 em apps vibecodados. O modelo cria a tabela, não habilita RLS, e agora qualquer usuário autenticado lê tudo.
- **Policies restritivas por usuário** — não basta habilitar RLS; as policies precisam filtrar por `auth.uid()`.
- **Service role key NUNCA no frontend** — a chave de serviço bypassa RLS. Se está no client-side, é como não ter RLS.

```sql
-- Exemplo de policy restritiva
CREATE POLICY "Users can only see own data"
ON profiles FOR SELECT
USING (auth.uid() = user_id);
```

### Secrets & Credenciais

```bash
# Procure secrets vazados no histórico do git
git log -p | grep -iE "(api_key|secret|password|token)" | head -20

# Verifique se .env está no .gitignore
grep ".env" .gitignore
```

- **Todas as API keys em variáveis de ambiente** — nunca hardcoded, nunca no repositório.
- `.env` **no** `.gitignore` — parece óbvio, mas o modelo nem sempre faz isso.
- Se uma key já foi commitada, **rotacione imediatamente**. Deletar o commit não basta — o histórico do git é público.

### Autenticação

- **Verificação server-side em TODAS as rotas protegidas** — middleware de auth, não checagem no frontend.
- **Email verification** antes de acesso completo.
- **Requisitos de senha**: mínimo 12 caracteres. Sim, 12. Em 2026, 8 é insuficiente.
- **Session timeout** configurado — sessões eternas são convite pra session hijacking.
- **Logout limpa sessão** — teste manualmente: faça logout, copie o token antigo, tente usar. Se funcionar, tem bug.

### API

```bash
# Teste básico: tente acessar dados de outro usuário
curl -H "Authorization: Bearer TOKEN_USER_A" \
  https://seuapp.com/api/users/USER_B_ID/data
# Se retornar 200, você tem um problema sério.
```

- **Verificação de ownership** — toda rota que retorna dados deve checar se o recurso pertence ao usuário autenticado.
- **Input validation com schema** — use Zod, Joi, ou equivalente. Não confie em nada que vem do client.
- **Rate limiting em endpoints públicos** — login, signup, password reset. Sem isso, brute force é trivial.
- **Error messages genéricas** — `"Credenciais inválidas"`, não `"Usuário não encontrado"` vs `"Senha incorreta"`. A diferença vaza informação.
- **CORS restrito** — apenas seus domínios, não `*`.

```typescript
// Exemplo com Zod
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  password: z.string().min(12),
});

// No handler
const parsed = CreateUserSchema.safeParse(req.body);
if (!parsed.success) {
  return res.status(400).json({ error: "Invalid input" });
}
```

### Security Headers

Se você usa Vercel, Netlify, ou qualquer plataforma moderna, configurar headers é questão de um arquivo:

```json
// vercel.json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self'" }
      ]
    }
  ]
}
```

Cinco minutos de configuração. Protege contra clickjacking, MIME sniffing, e uma série de ataques comuns. Não tem desculpa pra não fazer.

## Checklist de Performance & Infra

A AI gera código que funciona. Não gera código que escala. Essa é uma distinção que só quem já viu um sistema sob carga real entende.

- **`npm audit` / `yarn audit`** — rode antes de cada deploy. Dependências com vulnerabilidades conhecidas são porta aberta.
- **Source maps desabilitados em produção** — seu código-fonte não precisa estar legível no browser do usuário.
- **Sem `console.log` com dados sensíveis** — o modelo adora colocar logs de debug. Em produção, isso é vazamento de informação.
- **Bundle size** — o modelo não otimiza imports. Verifique se não está mandando 2MB de JavaScript pro client.
- **Lazy loading** em rotas e componentes pesados.
- **Imagens otimizadas** — WebP/AVIF, com dimensões corretas. Next.js Image ou equivalente.

```bash
# Analise o bundle
npx webpack-bundle-analyzer stats.json
# ou para Next.js
ANALYZE=true next build
```

### Banco de dados em carga

- **Índices nas queries frequentes** — o modelo cria tabelas, raramente cria índices. Uma query sem índice numa tabela com 100k registros é um timeout garantido.
- **Connection pooling** — se está usando Supabase/Postgres direto, configure o pgBouncer ou equivalente.
- **N+1 queries** — o padrão favorito do código gerado por AI. Use `EXPLAIN ANALYZE` nas queries principais.

```sql
-- Encontre queries lentas (Postgres)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## Checklist Operacional

Essa é a parte que separa "projeto pessoal" de "produto". Se você pretende ter usuários reais — mesmo que poucos — precisa conseguir responder: *"O que aconteceu às 3h da manhã quando o sistema parou?"*

- **Monitoramento básico** — Uptime (UptimeRobot é grátis), error tracking (Sentry tem free tier), métricas de performance.
- **Logging estruturado** — não `console.log("deu erro")`. Use JSON com timestamp, request ID, contexto.
- **CI/CD** — deploy manual é receita pra desastre. GitHub Actions com testes automatizados no mínimo.
- **Plano de rollback** — se o deploy quebrar produção, quanto tempo leva pra voltar? Se a resposta é "não sei", você não está pronto.
- **Backup do banco** — testado. Backup que nunca foi restaurado não é backup, é esperança.

```yaml
# .github/workflows/deploy.yml (exemplo mínimo)
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
      # deploy só passa se lint + tests passarem
```

## O que só experiência ensina

Posso dar checklists o dia inteiro. Mas tem coisas que nenhuma lista cobre:

**Edge cases que o modelo não imagina.** O que acontece quando o usuário cola 50MB de texto num campo de input? Quando a timezone do servidor é diferente da timezone do usuário? Quando o webhook do Stripe chega *antes* do redirect do checkout completar? Esses cenários só aparecem quando você já viu sistemas quebrarem de formas criativas.

**Scaling não é linear.** Funcionar com 10 usuários não garante funcionar com 1.000. O banco que respondia em 20ms começa a levar 2 segundos. O WebSocket que era estável começa a dropar conexões. A fatura do cloud que era $5 vira $500.

**Manutenção é o trabalho real.** O app que você vibecodou em um fim de semana vai precisar de updates, bugfixes, mudanças de API, migrations de banco. Se você não entende o código que o modelo gerou, cada mudança vira um jogo de roleta.

## Conclusão: ferramenta, não substituto

Vibe coding é uma ferramenta poderosa. Eu uso AI todos os dias no meu trabalho e recomendo que todo dev faça o mesmo. Mas ferramenta poderosa na mão de quem não sabe o que está fazendo causa mais estrago, não menos.

Se você é dev: use vibe coding pra acelerar, mas aplique sua experiência em tudo que o modelo gera. Revise segurança, teste edge cases, configure infra como você sempre fez.

Se você não é dev: respeite o gap. Um app no ar com dados de usuários reais é responsabilidade real. Contrate alguém pra fazer o review, ou no mínimo passe pelo checklist deste artigo item por item.

**O primeiro deploy é 10-20% do trabalho.** Os outros 80% são o que separa um app de um produto.

---

*Esse artigo faz parte da minha série sobre AI-augmented development. Se você quer receber os próximos, me segue no [GitHub](https://github.com/nat-rib) ou acompanha o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
