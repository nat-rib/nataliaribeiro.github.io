---
title: "Context Engineering: Como CLAUDE.md, Hooks e Skills Transformam o Claude Code em um Agente Personalizado"
date: 2026-03-03
description: "Context engineering é a skill #1 do agentic coding. Veja como CLAUDE.md, hooks e slash commands transformam o Claude Code de um assistente genérico em um agente que conhece você, seu projeto e seu fluxo."
tags: ["context-engineering", "claude-code", "hooks", "skills", "agentic-coding", "customização"]
categories: ["AI Development", "Agentic Engineering"]
slug: "context-engineering-claude-code"
keywords:
  - context engineering
  - CLAUDE.md
  - hooks
  - skills
  - Claude Code
  - customização
  - agentic coding
  - slash commands
draft: false
---

**Context engineering não é sobre prompt engineering. É sobre construir o ambiente que faz o AI trabalhar como se já te conhecesse.**

Se você usa Claude Code (ou qualquer AI CLI) todo dia, já viveu isso: na primeira sessão, tudo funciona. Na décima, você percebe que está repetindo as mesmas instruções. O modelo é poderoso — mas ele começa do zero toda vez.

O problema nunca foi a inteligência do modelo. Foi o **contexto**.

## O que é Context Engineering

Em janeiro de 2026, a Anthropic publicou o [relatório de tendências de agentic coding](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf) que posiciona **context engineering** como a competência mais importante para quem trabalha com AI agents. Não é exagero: 57% das empresas já rodam agentes de IA em produção, e a diferença entre "funciona mais ou menos" e "funciona de verdade" quase sempre é contexto.

Context engineering é a prática de **projetar o ambiente informacional** em torno do modelo. Não é escrever prompts melhores — é garantir que o modelo tenha acesso ao que precisa *antes* de você pedir qualquer coisa.

No Claude Code, isso se traduz em três mecanismos:

<table>
<thead>
<tr>
<th>Mecanismo</th>
<th>O que faz</th>
<th>Quando age</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>CLAUDE.md</strong></td>
<td>Define identidade, regras e convenções</td>
<td>Sempre (carregado automaticamente)</td>
</tr>
<tr>
<td><strong>Hooks</strong></td>
<td>Injeta contexto e valida output automaticamente</td>
<td>Em eventos específicos (início, escrita, fim)</td>
</tr>
<tr>
<td><strong>Slash Commands</strong></td>
<td>Workflows reutilizáveis sob demanda</td>
<td>Quando você invoca</td>
</tr>
</tbody>
</table>

Juntos, eles transformam o Claude Code de um assistente genérico em um **agente personalizado** que conhece seu projeto, seu estilo e suas regras.

## CLAUDE.md — O DNA do seu projeto

O arquivo `CLAUDE.md` na raiz do projeto é o primeiro arquivo que o Claude Code lê ao iniciar. É a sua chance de dizer tudo que o modelo precisa saber *sem repetir em cada sessão*.

Um CLAUDE.md ruim é uma lista de regras genéricas. Um CLAUDE.md eficaz é uma **carta de contexto** que muda o comportamento do modelo de forma observável.

### Anatomia de um CLAUDE.md real

Aqui está a estrutura do CLAUDE.md que uso no meu vault Obsidian (editado para clareza):

```markdown
# OrbitOS Vault — Claude Code CLI

Vault Obsidian da **Tsunowa** gerenciado por dois agentes:
Claude Code CLI (este) e R2-D2 (OpenClaw).

## Identidade
- **Usuária:** Tsunowa (Natália)
- **Idioma:** Português brasileiro
- **R2-D2:** Agente OpenClaw (Claude Haiku) — crons diários
- **Claude CLI:** Este contexto — interações diretas, pipeline de conhecimento

## Estrutura OrbitOS
00_Inbox/        → Captura rápida, ideias não processadas
10_Daily/        → Notas diárias (YYYY-MM-DD.md)
20_Project/      → Projetos ativos
40_Wiki/         → Conceitos atômicos + Claims/
99_System/       → Configuração, Archives, MOCs, Templates

## Regras de Escrita

### YAML Frontmatter (obrigatório)
title: "Título descritivo"
description: "Uma linha explicando o conteúdo"
tags: [tag1, tag2]
created: YYYY-MM-DD

### Convenções
- **Wiki Links:** [[Nome da Nota]] para conectar
- **Claims como prosa** — título funciona como afirmação
- **Nunca deletar notas** — mover para Archives/
- **Verificar duplicatas** antes de criar nota nova
```

### O que faz um CLAUDE.md funcionar

Tem quatro seções que fazem diferença real:

**1. Identidade e escopo** — Quem usa, que idioma, qual é o papel desse agente. Sem isso, o Claude pode responder em inglês, ignorar convenções de nomeação, ou conflitar com outros agentes.

**2. Estrutura do projeto** — Mapa claro das pastas e o que cada uma contém. O modelo usa isso para saber *onde* colocar coisas. Sem o mapa, ele cria arquivos em locais errados.

**3. Regras de escrita** — Schemas obrigatórios, convenções de naming, padrões de frontmatter. Regras que você verificaria manualmente se o modelo não soubesse.

**4. Tensões conhecidas** — Isso é o diferencial. Documentar problemas que você já identificou ("sistema captura muito, executa pouco") muda como o modelo prioriza sugestões.

### Anti-patterns de CLAUDE.md

- **Ser vago demais:** "Escreva código limpo" não muda nada. "Use type hints em todos os parâmetros e retorno, docstrings apenas em funções públicas" muda.
- **Ser extenso demais:** Se passa de 200 linhas, o modelo dilui o contexto. Seja cirúrgico.
- **Não atualizar:** Um CLAUDE.md desatualizado é pior que nenhum — gera comportamento incorreto com confiança.

## Hooks — Automação invisível

Hooks são scripts shell que rodam automaticamente em eventos do Claude Code. São o mecanismo mais poderoso e menos discutido de context engineering.

Existem três tipos de hooks que uso na prática:

### Hook 1: Session Orient (SessionStart)

**O que faz:** Injeta contexto do vault no início de cada sessão. O Claude já começa sabendo o estado atual do projeto.

```json
// .claude/settings.local.json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/session-orient.sh",
        "timeout": 10
      }]
    }]
  }
}
```

O script real:

```bash
#!/bin/bash
# OrbitOS — Session Orientation Hook

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Tracking de sessão
SESSION_ID=$(echo "$(cat)" | jq -r '.session_id // empty')
mkdir -p 99_System/sessions
TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")

# Arquiva sessão anterior se diferente
if [ -f 99_System/sessions/current.json ]; then
  PREV_ID=$(jq -r '.id // empty' 99_System/sessions/current.json)
  if [ "$PREV_ID" != "$SESSION_ID" ]; then
    mv 99_System/sessions/current.json \
       "99_System/sessions/${TIMESTAMP}.json"
  fi
fi

# Registra nova sessão
cat > 99_System/sessions/current.json << EOF
{"id": "$SESSION_ID", "started": "$TIMESTAMP", "status": "active"}
EOF

# Injeta contexto
echo "## OrbitOS Vault — Session Start"

# Status do inbox
INBOX_COUNT=$(find 00_Inbox/ -name "*.md" | wc -l | tr -d ' ')
[ "$INBOX_COUNT" -gt 0 ] && echo "INBOX: $INBOX_COUNT itens pendentes"

# Último plano diário
LATEST_PLAN=$(ls -t 10_Daily/20*.md 2>/dev/null | head -1)
[ -n "$LATEST_PLAN" ] && head -30 "$LATEST_PLAN"

# Sessão anterior
[ -f 99_System/sessions/current.json ] && \
  cat 99_System/sessions/current.json
```

**O efeito:** Ao iniciar uma sessão, o Claude já sabe quantos itens estão no inbox, qual foi o último plano diário, e o que aconteceu na sessão anterior. Sem esse hook, eu gastaria 2-3 minutos explicando "onde paramos".

### Hook 2: Write Validate (PostToolUse)

**O que faz:** Toda vez que o Claude escreve um arquivo `.md` no vault, o hook verifica se o frontmatter YAML está correto. Se faltar `description`, `tags`, ou campos obrigatórios de claims, o hook retorna um aviso que o Claude lê e corrige automaticamente.

```bash
#!/bin/bash
# Valida schema YAML em notas do vault

FILE=$(echo "$(cat)" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

case "$FILE" in
  */00_Inbox/*|*/40_Wiki/*|*/99_System/*)
    WARNS=""
    head -1 "$FILE" | grep -q "^---$" || WARNS+="Missing YAML. "
    head -20 "$FILE" | grep -q "^description:" || WARNS+="Missing description. "
    head -20 "$FILE" | grep -q "^tags:" || WARNS+="Missing tags. "

    # Claims precisam de type e domain
    case "$FILE" in
      */40_Wiki/Claims/*)
        head -20 "$FILE" | grep -q "^type: claim" || WARNS+="Missing type. "
        head -20 "$FILE" | grep -q "^domain:" || WARNS+="Missing domain. "
        ;;
    esac

    [ -n "$WARNS" ] && echo "{\"additionalContext\": \"Schema warnings: $WARNS\"}"
    ;;
esac
```

**O efeito:** Antes desse hook, ~30% das notas criadas pelo Claude tinham frontmatter incompleto. Depois, praticamente zero. O modelo recebe o feedback e corrige na mesma operação.

### Hook 3: Session Capture (Stop)

**O que faz:** Ao encerrar a sessão, salva o estado atual — quais arquivos foram modificados, timestamp de início/fim — e faz commit automático do estado da sessão.

```bash
#!/bin/bash
# Captura estado ao fechar sessão

TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")

# Atualiza status para "ended"
jq --arg ts "$TIMESTAMP" '.status = "ended" | .ended = $ts' \
  99_System/sessions/current.json > tmp.json && mv tmp.json \
  99_System/sessions/current.json

# Captura arquivos modificados
MODIFIED=$(git diff --name-only HEAD~5 | head -20)
MODIFIED_JSON=$(echo "$MODIFIED" | jq -R -s 'split("\n") | map(select(. != ""))')
jq --argjson files "$MODIFIED_JSON" '.files_modified = $files' \
  99_System/sessions/current.json > tmp.json && mv tmp.json \
  99_System/sessions/current.json

# Commit automático
git add 99_System/sessions/
git commit -m "Session end: $TIMESTAMP" --quiet 2>/dev/null
```

**O efeito:** Continuidade entre sessões. Quando o session-orient roda na próxima sessão, ele lê o `current.json` e o Claude sabe exatamente onde parou.

### O ciclo dos três hooks

```
┌─ SessionStart ──────────────────────┐
│  session-orient.sh                  │
│  → Injeta: inbox, plano, sessão    │
│  → Claude começa com contexto      │
└─────────────────────────────────────┘
          ↓ (sessão ativa)
┌─ PostToolUse (Write) ──────────────┐
│  write-validate.sh                  │
│  → Valida frontmatter YAML         │
│  → Claude corrige automaticamente  │
└─────────────────────────────────────┘
          ↓ (sessão termina)
┌─ Stop ──────────────────────────────┐
│  session-capture.sh                 │
│  → Salva estado, arquivos tocados   │
│  → Commit automático                │
│  → Alimenta próximo session-orient  │
└─────────────────────────────────────┘
```

## Slash Commands — Workflows sob demanda

Slash commands customizados são arquivos `.md` dentro de `.claude/commands/` que viram comandos `/nome-do-arquivo` no Claude Code. São a forma mais elegante de criar **workflows reutilizáveis**.

### Exemplos reais que uso diariamente

**`/start-my-day`** — Planejamento diário. O comando lê o último plano em `10_Daily/`, verifica carry-over de tarefas, analisa projetos ativos em `20_Project/`, e gera o plano do dia.

```markdown
# /start-my-day — Planejamento Diário OrbitOS

## Instrução

### Passos
1. Leia o último Daily Plan em 10_Daily/
2. Leia o último PDCA/Aprendizado em Archives/
3. Verifique projetos ativos em 20_Project/
4. Gere plano do dia com prioridades
```

**`/pipeline`** — Pipeline end-to-end de processamento de conhecimento. Pega uma fonte (URL, arquivo, texto) e roda o pipeline 6Rs: Record → Reduce → Reflect → Reweave → Verify. Transforma material bruto em claims atômicas conectadas ao grafo de conhecimento.

**`/rethink`** — Análise metacognitiva. Desafia premissas do sistema, identifica contradições, gaps e tensões. É o nível mais alto do pipeline — metacognição sobre o próprio sistema de conhecimento.

**`/health`** — Diagnóstico rápido. Conta arquivos, verifica atividade recente, checa saúde geral do vault. Versão leve do `/verify`.

### Como criar seu próprio slash command

Crie um arquivo `.md` em `.claude/commands/`:

```markdown
# /meu-comando — Descrição curta

## Instrução

Passos que o Claude deve seguir:

1. Passo 1 — o que fazer
2. Passo 2 — o que fazer
3. Passo 3 — o que fazer

## Contexto necessário

- **Diretório:** caminho/para/arquivos
- **Formato:** como o output deve ser
```

O arquivo `$ARGUMENTS` no conteúdo será substituído pelo que você digitar depois do comando. Exemplo: `/pipeline https://artigo.com` → `$ARGUMENTS` vira `https://artigo.com`.

## Antes vs Depois: O que muda com Context Engineering

### Sem context engineering

```
Eu: "Crie uma nota sobre machine learning no vault"

Claude: Cria arquivo ML.md na raiz do projeto.
        Sem frontmatter YAML.
        Sem wiki links.
        Em inglês.
        Título genérico.
```

Resultado: arquivo inútil que precisa ser refeito manualmente.

### Com context engineering

```
Eu: "Crie uma nota sobre machine learning no vault"

CLAUDE.md diz:
  → Idioma: português brasileiro
  → Notas vão em 40_Wiki/ ou 00_Inbox/
  → Frontmatter obrigatório: title, description, tags, created
  → Usar [[wiki links]] para conectar conceitos existentes

session-orient.sh injetou:
  → Existem 3 claims sobre AI em 40_Wiki/Claims/
  → Último plano mencionava pesquisa sobre modelos de linguagem

Claude: Cria 40_Wiki/Machine Learning.md com:
        - Frontmatter completo em português
        - [[wiki links]] para claims existentes sobre AI
        - Conexão com notas do último plano diário

write-validate.sh verifica:
  → ✓ YAML presente
  → ✓ description presente
  → ✓ tags presentes
```

Resultado: nota integrada ao sistema, conectada, validada. Sem intervenção manual.

### A diferença em números

<table>
<thead>
<tr>
<th>Métrica</th>
<th>Sem context eng.</th>
<th>Com context eng.</th>
</tr>
</thead>
<tbody>
<tr>
<td>Setup por sessão</td>
<td>3-5 min</td>
<td>0 (automático)</td>
</tr>
<tr>
<td>Notas com schema correto</td>
<td>~70%</td>
<td>~99%</td>
</tr>
<tr>
<td>Retrabalho manual</td>
<td>Frequente</td>
<td>Raro</td>
</tr>
<tr>
<td>Continuidade entre sessões</td>
<td>Inexistente</td>
<td>Automática</td>
</tr>
<tr>
<td>Workflows reproduzíveis</td>
<td>0</td>
<td>8 comandos ativos</td>
</tr>
</tbody>
</table>

## Como começar

Se você não tem nenhum context engineering configurado, comece com isso:

### Hoje (15 minutos)
Crie um `CLAUDE.md` na raiz do seu projeto com:
- Quem é você e que idioma usar
- Estrutura de pastas do projeto
- 3-5 regras que você sempre repete

### Esta semana (30 minutos)
Crie um hook `SessionStart` que injeta contexto básico:
- Status do git (`git status --short`)
- Último commit (`git log --oneline -5`)
- TODOs pendentes

### Próxima semana (45 minutos)
Crie um slash command para o workflow que você mais repete. Pode ser `/deploy`, `/review`, `/test`, ou qualquer ritual que tem passos fixos.

### Regra de ouro
Se você explicou a mesma coisa para o Claude mais de 3 vezes, ela deveria estar no CLAUDE.md. Se você executou a mesma sequência de passos mais de 3 vezes, ela deveria ser um slash command. Se você verifica manualmente algo que pode ser automatizado, deveria ser um hook.

## Conclusão

Context engineering é a diferença entre **usar** AI e **trabalhar com** AI. Prompt engineering otimiza uma interação. Context engineering otimiza todas as interações futuras.

O Claude Code já tem a infraestrutura — CLAUDE.md, hooks, slash commands. A maior parte das pessoas não usa. As que usam, não voltam atrás.

O investimento é pequeno: um arquivo de contexto, dois ou três hooks, alguns comandos. O retorno é permanente: cada sessão começa exatamente onde a última parou, cada output segue suas regras, cada workflow roda igual toda vez.

Não é sobre fazer o modelo mais inteligente. É sobre dar ao modelo o que ele precisa para ser útil.

---

*Esse artigo faz parte da série "Agentic Engineering na Prática". Semana 1: Context Engineering. Na próxima semana: como hooks avançados e MCP servers expandem o que o Claude Code pode fazer.*

---

*Me siga no [GitHub](https://github.com/nat-rib) ou acompanhe o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/) para mais sobre agentic engineering.*
