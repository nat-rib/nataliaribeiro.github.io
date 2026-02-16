---
title: "RAG vs MCP vs AI Agents vs Skills — O que são e quando usar cada um"
date: 2026-02-16
description: "Guia prático sobre RAG, MCP, AI Agents e Skills: o que cada um faz, quando usar, e como funcionam juntos. Por uma dev senior que usa isso no dia a dia."
tags: ["ai-agents", "rag", "mcp", "skills", "LLM", "arquitetura"]
categories: ["AI Development"]
slug: "rag-mcp-agents-skills"
keywords:
  - RAG vs MCP diferença
  - MCP model context protocol
  - AI agents tools skills
  - RAG retrieval augmented generation
  - quando usar RAG ou MCP
  - agent skills AI
draft: false
---

Todo mundo fala de RAG, MCP, Agents e Skills. Metade das pessoas usa como sinônimos. A outra metade acha que são tecnologias concorrentes e que precisa "escolher uma".

Nenhum dos dois está certo.

Eu trabalho com AI agents no meu dia a dia como dev. Uso RAG, configuro MCP servers, escrevo Skills, e orquestro tudo com agents. E a coisa que mais vejo — até entre devs experientes — é confusão sobre onde um termina e o outro começa.

Este artigo é o guia que eu gostaria de ter lido quando comecei a montar meu primeiro setup com agents. Sem hype, com exemplos concretos e analogias que realmente ajudam.

## RAG — A biblioteca com um bibliotecário eficiente

**RAG (Retrieval-Augmented Generation)** resolve um problema simples: LLMs não sabem tudo. Especificamente, não sabem nada sobre *seus* dados — sua documentação interna, suas FAQs, seu codebase.

### Como funciona

1. Você pega seus documentos e divide em pedaços (chunks)
2. Cada chunk vira um vetor numérico (embedding) e é armazenado num banco vetorial
3. Quando alguém faz uma pergunta, o sistema busca os chunks mais relevantes por similaridade semântica
4. Esses chunks são injetados no prompt do LLM como contexto
5. O modelo responde com base nesse contexto enriquecido

### A analogia

Imagine um profissional brilhante que acabou de ser contratado. Ele é inteligente, articula bem, raciocina rápido — mas não sabe nada sobre a empresa. RAG é dar a ele acesso a uma biblioteca organizada com toda a documentação interna, e um bibliotecário eficiente que busca exatamente o documento certo pra cada pergunta.

O profissional continua não podendo *fazer* nada na empresa (não tem acesso a sistemas, não pode mandar emails, não pode aprovar PRs). Mas agora ele *sabe* sobre a empresa.

### Quando usar

- Base de conhecimento interna (documentação, wikis, runbooks)
- FAQs e suporte ao cliente
- Busca semântica em documentos longos
- Qualquer cenário onde o problema é "o modelo não sabe X"

### Quando NÃO usar

- Dados que mudam em tempo real (preços, status de deploy, métricas)
- Quando você precisa de *ações*, não apenas respostas
- Quando os dados já cabem no contexto do modelo (janela de contexto grande o suficiente)

## MCP — O adaptador universal de ferramentas

**MCP (Model Context Protocol)** resolve outro problema: LLMs não interagem com o mundo externo. Eles geram texto. Ponto. Se você quer que o modelo consulte uma API, leia um banco de dados, ou mande uma mensagem no Slack, precisa de uma ponte.

### Como funciona

MCP é um protocolo padronizado — pense nele como uma especificação, não uma ferramenta. Ele define:

- Como o modelo **descobre** quais ferramentas estão disponíveis
- Como o modelo **invoca** uma ferramenta (com quais parâmetros)
- Como o modelo **recebe** o resultado de volta

Na prática, você roda "MCP servers" — pequenos serviços que expõem ferramentas via esse protocolo. Um MCP server pro GitHub, outro pro Slack, outro pro seu banco de dados.

### A analogia

MCP é um adaptador universal de tomada. Ele não gera energia (não faz nada sozinho) e não é o aparelho que você quer usar (não é o agent). Ele é o padrão que permite que qualquer aparelho se conecte a qualquer tomada.

Antes do MCP, cada ferramenta de AI tinha sua própria forma de integrar com APIs externas. Era como viajar pela Europa antes dos adaptadores universais — cada país com seu formato de tomada.

### Quando usar

- Dados dinâmicos em tempo real (APIs, bancos, serviços)
- Integração com ferramentas existentes (GitHub, Jira, Slack, bancos de dados)
- Qualquer cenário onde o modelo precisa *agir* no mundo, não apenas *saber* sobre ele

### Quando NÃO usar

- Conhecimento estático que não muda (use RAG)
- Quando não existe um MCP server pro serviço que você quer (ainda precisa desenvolver um, ou usar function calling direto)

## AI Agents — O profissional completo

**AI Agents** são a camada que orquestra tudo. Enquanto RAG fornece conhecimento e MCP fornece acesso a ferramentas, o agent é quem *decide* o que fazer, *quando* fazer, e *como* combinar os recursos disponíveis.

### Como funciona

Um agent é essencialmente um loop:

1. **Observa** — recebe input do usuário ou do ambiente
2. **Raciocina** — analisa o contexto, planeja os próximos passos
3. **Decide** — escolhe qual ação tomar
4. **Age** — executa a ação (usando MCP, RAG, ou outros recursos)
5. **Repete** — avalia o resultado e decide se precisa de mais passos

Isso é fundamentalmente diferente de um simples "chat com AI". Um chatbot responde sua pergunta e pronto. Um agent pode receber "deploy a nova versão do serviço X" e, sozinho: verificar se os testes passaram, fazer o build, rodar migrations, deploy, verificar health checks, e te avisar se algo deu errado.

### A analogia

O agent é o profissional completo. Ele sabe pensar e tomar decisões (LLM), tem acesso às ferramentas certas (MCP), consulta referências quando precisa (RAG), e segue procedimentos estabelecidos (Skills).

Sem o agent, você tem peças soltas. RAG é uma biblioteca sem ninguém pra consultar. MCP é um kit de ferramentas sem ninguém pra usar. Skills é um manual sem ninguém pra ler. O agent é quem dá vida a tudo isso.

### Quando usar

- Tarefas multi-step que exigem raciocínio e decisão
- Automação de workflows complexos
- Qualquer cenário onde a resposta certa depende de *contexto* e *julgamento*

### Cuidado

Quanto mais autonomia você dá ao agent, mais risco. Guardrails, observabilidade e limites claros são essenciais. Um agent com acesso total à sua infra e zero supervisão é um incidente esperando pra acontecer.

## Skills — O manual de procedimentos sob demanda

**Skills** são o conceito mais recente e talvez o menos intuitivo dos quatro. Resolvem um problema prático: prompts longos degradam a performance do agent.

### Como funciona

Em vez de carregar um prompt gigante com instruções pra *tudo* que o agent pode fazer, você mantém um catálogo leve — nome e descrição de cada skill. Quando o agent identifica que precisa de uma skill específica, carrega só aquele conjunto de instruções no contexto.

Pense em skills como **playbooks reutilizáveis**: instruções detalhadas, passo a passo, pra tarefas específicas.

### A analogia

Imagine um médico. Ele não memoriza todos os protocolos de todos os procedimentos. Ele sabe *quais* protocolos existem e, quando precisa de um específico, consulta o manual. Skills funcionam igual: o agent sabe o que pode fazer, e carrega as instruções detalhadas sob demanda.

### Exemplo prático

No meu setup com [OpenClaw](https://openclaw.com), tenho skills separadas para:

- **Pesquisa web** — como buscar, validar fontes, sintetizar informação
- **Escrita de artigos** — tom, estrutura, checklist de qualidade
- **Deploy** — procedimentos de deploy com verificações de segurança
- **Code review** — o que verificar, padrões a seguir, red flags

Cada uma é um arquivo markdown com instruções detalhadas. O agent carrega só a que precisa, quando precisa.

### Quando usar

- Tarefas recorrentes com procedimentos bem definidos
- Quando o agent precisa de instruções detalhadas mas você não quer poluir o contexto base
- Padronização de processos entre múltiplos agents ou sessões

## Tabela comparativa

| Aspecto | RAG | MCP | AI Agents | Skills |
|---------|-----|-----|-----------|--------|
| **Problema que resolve** | "O que o modelo sabe" | "Como usa ferramentas" | "Quem decide e age" | "Como executa tarefas" |
| **Tipo de dado** | Estático, documentos | Dinâmico, APIs/serviços | Tudo (orquestra) | Instruções procedurais |
| **Quando atua** | Na construção do prompt | Em runtime, sob demanda | Loop contínuo | Carregamento sob demanda |
| **Resultado** | Respostas melhores | Ações no mundo real | Tarefas completas | Execução padronizada |
| **Compete com os outros?** | Não | Não | Não | Não |

A linha mais importante da tabela é a última: **nenhum deles compete com o outro**. São camadas complementares de um mesmo stack.

## Como funcionam juntos — um cenário real

Vou dar um exemplo concreto de como os quatro se combinam. Digamos que você pede ao seu agent: *"Analisa o PR #142 do repositório X e me dá um review."*

Aqui está o que acontece por baixo dos panos:

1. **O Agent** recebe o pedido e raciocina: "Preciso buscar o PR, entender o contexto do projeto, analisar o código, e dar feedback"

2. **Carrega a Skill** de code review — instruções detalhadas sobre o que verificar: segurança, performance, padrões do projeto, testes

3. **Usa MCP** (GitHub server) para buscar o diff do PR #142, os comentários existentes, e o CI status

4. **Usa RAG** para buscar a documentação de arquitetura do projeto e os padrões de código da equipe — informação que está no knowledge base interno

5. **O Agent** sintetiza tudo: o diff (via MCP), o contexto do projeto (via RAG), seguindo os procedimentos de review (via Skill), e gera um review estruturado

6. **Usa MCP** de novo para postar o review como comentário no PR

Nenhuma peça funciona sozinha. O RAG sem o agent é uma biblioteca fechada. O MCP sem o agent é um kit de ferramentas na prateleira. As Skills sem o agent são manuais que ninguém lê. O agent sem RAG, MCP e Skills é um profissional brilhante mas sem recursos.

## O que isso significa na prática

Se você está começando a trabalhar com AI agents, minha sugestão:

1. **Comece pelo agent** — sem um orquestrador, as outras peças não fazem sentido isoladamente
2. **Adicione MCP** quando precisar que o agent interaja com ferramentas externas
3. **Adicione RAG** quando o agent precisar de conhecimento que não está no treinamento do modelo
4. **Crie Skills** quando perceber que está repetindo as mesmas instruções em prompts diferentes

Não tente montar tudo de uma vez. Cada camada resolve um problema específico. Adicione conforme a necessidade real aparece.

## Conclusão

RAG, MCP, AI Agents e Skills não são tecnologias concorrentes — são camadas complementares que, juntas, formam um sistema de AI realmente útil. O agent é o cérebro que orquestra. RAG é a memória de longo prazo. MCP é o sistema nervoso que conecta com o mundo externo. Skills são os procedimentos aprendidos.

A confusão entre esses conceitos é normal — a área está evoluindo rápido e a terminologia ainda está se estabilizando. Mas entender o papel de cada um é o que separa "brincar com AI" de "construir sistemas com AI que funcionam de verdade".

E no fim do dia, é isso que importa: sistemas que funcionam de verdade, resolvendo problemas reais.

---

*Esse artigo faz parte da minha série sobre AI-augmented development. Se você quer receber os próximos, me segue no [GitHub](https://github.com/nat-rib) ou acompanha o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
