# DISCOVERY · Recrutamento de Fornecedor · Empresa Inteligente OS · 2026-08-06 · v1

**Metodologia:** `~/.claude/rules/discovery-metodologia-padrao-obrigatoria.md` (6 passes)
**Base metodológica (não reinventar, só operacionalizar):**
- MSFE v1.0 — `~/csb-war-room/docs/metodologias/2026-08-06-selecao-fornecedor-estrategico-v1.md`
- FQF v1.1 — `~/csb-war-room/docs/metodologias/2026-08-06-formulario-qualificacao-fornecedor-v1.md`

Este documento não redefine a metodologia. Ele responde a uma pergunta diferente: **como vira produto** — quem usa, o que o sistema automatiza, o que o gestor decide, e o que fica fora do dia 1.

---

## 0 · VISÃO & ENTENDIMENTO DO PROJETO

### 0.1 · Por que este módulo precisa existir (JTBD)

O pedido inicial de Julio foi por uma *ferramenta de mineração e pontuação*. Aplicando os 5 porquês:

1. **Por que uma ferramenta?** — Porque hoje a seleção de fornecedor é feita por conversa e proposta, e a proposta não prediz o resultado.
2. **Por que a proposta não prediz?** — Porque o fornecedor mente sobre indicadores de gestão quando perguntado direto: *"isso também mentem"*.
3. **Por que isso importa a ponto de justificar um módulo de produto?** — Porque o padrão se repetiu em toda contratação de serviço contábil: *"na prática nenhuma empresa atende direito, enrolam, não tem processo, não cumprem prazo"*.
4. **Por que não bastam a MSFE e o FQF (que já existem em markdown)?** — Porque um framework em markdown não persiste candidato, não cruza fonte automaticamente, não gera pipeline visível para o gestor acompanhar, e principalmente **não impede que a próxima contratação, num momento de pressa, pule etapa** — que é exatamente o padrão de falha que gerou a dor original.
5. **Motivação final, não decomponível:** **dinheiro e tempo de gestão perdidos em ciclos de troca de fornecedor** — cada erro de contratação custa a parcela 5 do CTP (custo de troca, MSFE §1.6) inteira, e o padrão histórico é 100% de erro nas contratações anteriores relatadas.

**O que muda em 12 meses se der certo:** toda contratação de fornecedor estratégico (não só contábil) passa por um funil auditável, com candidato pontuado por evidência de terceiro antes de qualquer conversa comercial, e cada contratação (boa ou ruim) alimenta o loop de calibração da MSFE §9 — o framework deixa de ser uma checklist estática e começa a aprender.

**Frase-âncora do próprio Julio, que define o produto:** *"é igual processo seletivo só que de fornecedor"*. O módulo é um ATS (Applicant Tracking System) — só que o candidato é uma empresa fornecedora, não uma pessoa.

### 0.2 · O que já existe hoje (antes de desenhar algo novo)

| O que existe | Onde | Natureza |
|---|---|---|
| Metodologia completa (7 fases, 4 classes de critério, gate de contrato, loop de calibração) | `~/csb-war-room/docs/metodologias/2026-08-06-selecao-fornecedor-estrategico-v1.md` | Framework, 100% manual hoje — nenhuma linha de código o executa |
| Formulário de qualificação (10 blocos) + chave de leitura interna com armadilhas | `~/csb-war-room/docs/metodologias/2026-08-06-formulario-qualificacao-fornecedor-v1.md` | Documento a ser enviado manualmente ao fornecedor, hoje |
| Processo real de contratação anterior | relatado por Julio, não documentado em nenhum sistema | 100% ad hoc, sem registro estruturado — é por isso que a MSFE §9.4 declara o baseline de erro como "desconhecido" |
| Agentes de automação da metodologia | `estrategista-sourcing-fornecedor-estrategico` e `prospector-fornecedor-qualificado`, citados na MSFE §12 como pendentes | **Não existem ainda.** Precisam de Discovery formal própria via `especialista-discovery-agentes` — fora do escopo deste documento, que é Discovery de produto/módulo, não de agente |

**Não existe hoje nenhuma ferramenta, planilha ou pipeline ClickUp para recrutamento de fornecedor.** O módulo nasce do zero em termos de execução — a única coisa que já existe é a metodologia (o "o quê" e o "como avaliar"), não o "onde roda".

### 0.3 · O que já existe no produto que vai receber o módulo (achados de pré-flight, repo `~/empresa-inteligente/`)

Inventário feito por leitura direta de arquivo (sem `ls`/Glob disponíveis nesta sessão — ver limitação registrada em §0.3.1). Achados confirmados:

- **`~/empresa-inteligente/index.html`** — landing page institucional (marketing público, Google Ads ativo). Schema.org, GTM (`GTM-NG726JTZ`), tema `#D70030`.
- **`~/empresa-inteligente/sitemap.xml:113-154`** — 6 landing pages por **departamento** (`ia-para-financeiro`, `ia-para-comercial`, `ia-para-atendimento`, `ia-para-marketing`, `ia-para-rh`, `ia-para-operacao`), cada uma página estática própria com head/schema repetidos.
- **`~/empresa-inteligente/ia-para-contabilidade/index.html:1-40`** — landing page por **nicho vertical**, no mesmo padrão de marketing (título "IA para Escritórios de Contabilidade"), **mas não está listada no sitemap.xml** — página mais recente que o sitemap, ou sitemap desatualizado (achado a registrar, não resolver aqui).
- **`~/empresa-inteligente/contabilidade/index.html:1-25`** e **`~/empresa-inteligente/niche.css:1-58`** — um SEGUNDO padrão de página de nicho, template compartilhado (`niche.css`, prefixo de classe `.ei-*`, atributo `data-nicho="contabilidade"`), paleta `--red:#D70030 --black:#1D1D1F --gray:#86868B --light-gray:#F5F5F7`, tipografia Zen Dots (display) + Inter (corpo) — **coerente com a paleta KTANA (`#D70030`) já documentada em `~/.claude/rules/ktana-rules.md`**, mas é um token set PRÓPRIO deste repo (`niche.css`), não importado do design system KTANA formal.
- **`docs/discovery/`** não existia antes deste documento — criado agora.
- **Sem `README.md`, sem `package.json`, sem `CLAUDE.md` na raiz do repo** — é site estático servido direto (HTML/CSS puro), sem build step, sem framework, sem design system formal documentado (nenhum `design-system/` ou `_shared/` encontrado nos paths verificados).
- **`~/empresa-inteligente/diagnostico.html`** é um stub de redirect para `https://empresainteligente.ai/diagnostico` — o wizard de diagnóstico real roda em outro serviço (Next.js `ei-lead-form`, conforme `~/CLAUDE.md` "Traefik → nginx (LP em /) + ei-lead-form (Next.js em /diagnostico)"), **não neste repo**.
- **`.git/config`** — remote `github.com/ktanadev/empresa-inteligente.git`, branch `main` + 2 branches de feature em andamento (`feature/proposta-grupo-silva`, `fix/redesign-clean-liquid-glass`) — sinal de que há trabalho concorrente possível neste repo (aplicar `worktree-agents.md` quando a construção começar).
- **VPS de produção é zona protegida** (`~/CLAUDE.md`, seção "EMPRESAINTELIGENTE.AI — ZONA PROTEGIDA"): Google Ads ativo ~R$100/dia, deploy requer autorização nomeada, `ei-guardian.py` bloqueia deploy solto.

#### 0.3.1 · Limitação de ferramenta registrada (não inventar além disto)

Esta sessão não teve acesso a `Bash`/`Glob`/`LS` — só `Read` de paths exatos. Não foi possível fazer inventário exaustivo do repo (ex: confirmar TODAS as páginas de nicho existentes, `assets/`, eventual pasta `prototipos/` citada no briefing da tarefa mas não confirmada aqui). **Uma sessão futura com acesso a `Glob`/`Bash` deve rodar `ls -R` completo antes de qualquer construção**, não assumir que este inventário parcial é exaustivo.

### 0.4 · Modelo de negócio em uma frase — **pergunta em aberto, não assumida**

Duas hipóteses igualmente plausíveis pelo que existe hoje, e a diferença muda a arquitetura inteira (multi-tenant desde o dia 1 vs. ferramenta interna de um único tenant):

- **Hipótese A — ferramenta interna**: usada só pelo grupo de empresas do Julio (KTANA/CSB/EI) para as próprias contratações de fornecedor.
- **Hipótese B — módulo vendável do Empresa Inteligente OS**: a Notion "Empresa Inteligente OS — Copy Completa (Pitch)" já cita *"Acesso à plataforma Empresa Inteligente OS (bônus permanente)"* como parte da oferta comercial — se recrutamento de fornecedor é um módulo dessa plataforma vendida a clientes, é produto multi-tenant desde o início.

Isso é a primeira pergunta em aberto (ver §Perguntas em Aberto, eixo Escopo) — **nenhuma arquitetura de dado deste documento assume A ou B**; o roadmap V1 (§5) é desenhado para funcionar em ambos sem retrabalho estrutural.

### 0.5 · Cadeia de artefatos (onde este documento se encaixa)

```
1. MSFE v1.0 (metodologia)          → ~/csb-war-room/docs/metodologias/...selecao-fornecedor-estrategico-v1.md
2. FQF v1.1 (formulário + chave)    → ~/csb-war-room/docs/metodologias/...formulario-qualificacao-fornecedor-v1.md
3. ESTE DOCUMENTO (Discovery de produto/módulo)  → o que vira ferramenta, quem usa, o que é V1
4. [pendente] SPEC funcional/técnica → docs/scope/specs/ (FASE 1 GSD, só depois deste Discovery aprovado)
5. [pendente] Discovery de agente — `estrategista-sourcing-fornecedor-estrategico` e `prospector-fornecedor-qualificado` (via especialista-discovery-agentes, separado)
```

---

## 1 · ARQUITETURA

### 1.1 · Atores

| Ator | Papel | Poder de decisão |
|---|---|---|
| **Gestor** (Julio, e potencialmente outros gestores do grupo/clientes — ver §0.4) | Abre a vaga de fornecedor, recebe candidatos pontuados, decide avançar/eliminar em cada fase, aprova o piloto | Decisão final em toda fase — o sistema nunca contrata sozinho |
| **Sistema de originação/mineração** (hoje: framework MSFE F-1/F1 executado manualmente; alvo: agente `prospector-fornecedor-qualificado`, fora de escopo deste doc) | Constrói o universo de candidatos, coleta evidência multi-canal, calcula score | Não decide — só pontua e apresenta. Knockout automático é aplicação de regra fechada (MSFE §7 Etapa 1), não julgamento |
| **Advogado-contratos** (agente já existente, MSFE §6) | Analisa a oferta comercial do candidato aprovado, aplica o checklist G1-G10 | Veredito GO/AJUSTAR/NO-GO — vincula o gestor a não prosseguir sem ele |
| **Fornecedor candidato** | Responde o FQF, participa do piloto pago | Não tem acesso ao sistema — é objeto de avaliação, não usuário |
| **ClickUp** (sistema externo) | Hospeda o pipeline visual (fases = listas/status), é onde o gestor efetivamente trabalha o funil no dia a dia | Não decide nada — é a camada de apresentação/coordenação de trabalho |

**Achado relevante de pré-flight (Notion, "Guia SDR — Funil Empresa Inteligente"):** já existe um workspace ClickUp real (`app.clickup.com/9011677992/...`) usado para o funil COMERCIAL de leads (clientes que compram Empresa Inteligente), com padrão de Kanban (Lead Captado → Reunião Agendada → Reunião Feita → Proposta Enviada → Proposta Aceita → Perdido) e automação via n8n. Esse é um funil de **cliente**, não de **fornecedor** — não deve ser reaproveitado como o mesmo pipeline (misturaria lead comercial com candidato a fornecedor), mas é candidato natural a workspace-mãe para uma Lista/Space nova dedicada a fornecedor, e prova que o padrão "task ClickUp criada automaticamente a partir de um evento" já é usado com sucesso neste ecossistema (via n8n) — não é design novo, é reaplicação de um padrão que já funciona.

### 1.2 · Fluxo de dado (visão de alto nível, sem desenho detalhado — SPEC decide a implementação)

```
Gestor abre vaga (área/tipo de fornecedor + escopo + camada MSFE §1.5)
        ↓
[F-1 MSFE] Originação — universo de 15-25 candidatos por canal de competência
        ↓
[F1 MSFE] Mineração multi-canal por candidato (mín. 4 canais, MSFE §4)
        ↓
[F2 MSFE] Knockout de expertise (Classe D + C1) — candidato eliminado não avança
        ↓
Score calculado (Classe A 45 + Classe B 30 + Classe C 25 = 100)
        ↓
Candidato aprovado (score ≥ 55) vira CARD no pipeline ClickUp, na fase correspondente
        ↓
Gestor decide, fase a fase, dentro do ClickUp (avança / elimina / pede mais evidência)
        ↓
[F4 MSFE] Análise de contrato (advogado-contratos) → gate GO/AJUSTAR/NO-GO
        ↓
[F5 MSFE] Piloto pago — registrado e medido (MSFE §8) dentro do próprio card
        ↓
Contrato longo OU eliminação → linha entra no dataset de calibração (MSFE §9.2)
```

### 1.3 · Onde mora o estado — decisão de arquitetura em aberto, não resolvida aqui

Duas opções, com trade-off real:

- **ClickUp como fonte de verdade** (mais simples, sem banco próprio): campos customizados do ClickUp guardam score, canais consultados, knockouts, CTP estimado. Risco: ClickUp não foi feito para guardar histórico estruturado de calibração (MSFE §9.2, "uma linha por candidato avaliado, incluindo rejeitados") de forma consultável/analisável ao longo de anos — campo customizado não faz agregação estatística nem versiona critério.
- **Banco próprio (Postgres, seguindo o padrão do ecossistema) + ClickUp como VIEW/sincronização** (ClickUp mostra o card, mas o dado vive num banco): mais capaz para o loop de calibração (§9), mas é mais infraestrutura pro V1.

**Registrado como pergunta em aberto (eixo Arquitetura)** — a MSFE §9.2 exige dataset estruturado incluindo candidatos REJEITADOS (grupo de controle), o que só ClickUp sozinho dificilmente sustenta bem a longo prazo; mas resolver isso é decisão de SPEC/arquiteto, não deste Discovery.

### 1.4 · Automático × manual (mapa por fase, não fase a fase repetido em toda funcionalidade — ver §2 para o detalhe)

| Fase MSFE | Hoje (100% manual) | V1 deste módulo | Por quê |
|---|---|---|---|
| F-1 Originação | manual | assistido (humano cura, sistema ajuda a buscar) | sem fonte única "boa" para minerar universo de candidatos automaticamente sem julgamento humano de relevância |
| F0 Categorização | manual (conversa) | manual, via formulário de abertura de vaga | é decisão de negócio do gestor — nunca automatiza |
| F1 Mineração | manual, com bloqueio técnico conhecido (LinkedIn exige login) | **misto** — canais públicos automatizáveis, LinkedIn manual/assistido no V1 (ver §5) | restrição técnica real, não hipotética — ver §1.5 |
| F2 Knockout | manual (leitura humana) | automatizável (regra binária, closed-form) | knockout é regra fechada, dá para codificar sem IA generativa |
| F3 Prova performativa | 100% humano (reunião, teste) | 100% humano, sempre | não dá — nem deveria — para automatizar avaliar embasamento legal ao vivo |
| F4 Análise de contrato | via `advogado-contratos` (já existe como agente) | integração — o card ClickUp reflete o veredito | reaproveita agente existente, não cria um novo |
| F5 Piloto pago | manual | registro estruturado no card (dados de §8) | é execução real, não automatiza a entrega — automatiza o REGISTRO da medição |
| §9 Calibração | não existe | manual/assistido — retro de 4 perguntas por contratação encerrada | dataset pequeno (poucas contratações/ano) não pede automação estatística ainda (MSFE §9.5) |

### 1.5 · Requisitos não-funcionais P0

1. **LGPD** — o processo mina e armazena dado de PESSOA FÍSICA de terceiro (nome de analista no LinkedIn, depoimento de ex-funcionário no Glassdoor, nome do executor no formulário). Base legal provável: legítimo interesse (art. 7º, IX, Lei 13.709/2018) para finalidade de due diligence de fornecedor — **isso precisa de validação jurídica formal antes da SPEC**, não está resolvido aqui (ver "Especialistas complementares necessários", final do documento).
2. **ToS dos canais de mineração** — LinkedIn e Reddit têm restrição técnica JÁ CONFIRMADA (não hipotética): LinkedIn `/company/*/people/` exige sessão autenticada (MSFE §4, tabela); Reddit bloqueia user-agent padrão, funciona via navegador real em `old.reddit.com`. Automatizar raspagem persistente de LinkedIn levanta questão de ToS que este Discovery não resolve — registrado como risco P0 (§Perguntas em Aberto).
3. **Auditabilidade** — todo score e todo knockout precisa ser rastreável até a evidência que o gerou (arquivo:linha da fonte, print, ou link) — é o que dá à decisão do gestor caráter de "fato oponível" (MSFE §8), inclusive para eventual disputa com o fornecedor reprovado.
4. **Isolamento de zona protegida** — o módulo é ferramenta de gestão interna (decisão de contratação), não landing page pública. **Não deve nascer dentro da árvore servida como `empresainteligente.ai/` público** (zona de Google Ads ativo, `~/CLAUDE.md` "ZONA PROTEGIDA") — precisa de path/serviço próprio, isolado do site de marketing. Isso é uma recomendação de arquitetura a confirmar em SPEC, registrada aqui porque nasce direto do pré-flight (§0.3).

### 1.6 · Decisão de posicionamento — pergunta em aberto

Onde este módulo roda tecnicamente (dentro do repo `empresa-inteligente` como uma rota interna autenticada, ou como serviço/app separado que consome o mesmo domínio via subpath, seguindo `~/.claude/rules/slug-taxonomia-hierarquica-produto-modulo.md`) é decisão de SPEC/arquitetura, não deste Discovery — mas o requisito de NÃO tocar a zona protegida (§1.5.4) já elimina a opção "editar os arquivos estáticos do site de marketing direto".

---

## 2 · REGRAS DE NEGÓCIO (EXAUSTIVO)

Aplicando o checklist obrigatório (quem pode · limite · exceção · automático×manual · aprovação · histórico de tentativa anterior) a cada funcionalidade central.

### F-A · Abrir vaga de fornecedor

- **Quem pode:** o gestor (papel único confirmado hoje — Julio). Se a Hipótese B (§0.4) se confirmar, "quem pode" se expande para gestores de empresas-cliente da plataforma — **pergunta em aberto**, não resolvida aqui.
- **Limite:** nenhum limite de quantidade conhecido hoje (não há indicação de que abrir muitas vagas simultâneas seja um problema de negócio) — mas cada vaga aberta consome ciclo de mineração (F-1/F1), que tem custo operacional/de tempo. Sem dado de volume esperado (ver Pergunta em Aberto, eixo Volume), não é possível definir limite real.
- **Exceção:** nenhuma identificada — toda contratação de fornecedor estratégico (definição MSFE: "recorrente e crítico") deveria passar por aqui. Fornecedor pontual/não-recorrente (ex: compra única de material) está fora do escopo da MSFE por definição (MSFE, cabeçalho: "fornecedor de serviço profissional recorrente e crítico") — não é este módulo.
- **Automático × manual:** 100% manual — é declaração de intenção do gestor (área, camada MSFE §1.5, escopo).
- **Aprovação:** não se aplica — abrir vaga não é uma ação que precisa aprovação de terceiro.
- **Histórico de tentativa anterior:** nunca existiu essa etapa formalizada antes — é o ponto de partida novo que substitui "decidir contratar informalmente numa conversa".

**Campo obrigatório na abertura, derivado direto da MSFE:** **tipo de fornecedor** (contábil/BPO/CFOaaS, jurídico, fomento, TI, marketing, insumo/logística, consultoria — MSFE §2.1) — esse campo determina QUAL conjunto de Classe D (knockouts) e QUAL canal principal de Classe A se aplica. Sem esse campo, o sistema não sabe qual Bloco 6 do FQF usar.

### F-B · Originação e mineração de candidatos (F-1 + F1 MSFE)

- **Quem pode:** disparado pelo gestor (ou automaticamente ao abrir a vaga — decisão de SPEC).
- **Limite:** gate explícito da MSFE — **15-25 candidatos originados por canal de competência, nunca de preço** (MSFE §2, gate F-1). Mineração mínima de **4 canais por candidato**, senão o candidato fica em "dados insuficientes" e não pontua (MSFE §4).
- **Exceção:** candidato indicado diretamente pelo gestor (referência pessoal) entra no funil MESMO sem ter passado pela originação automática — mas ainda precisa dos 4 canais mínimos de mineração antes de pontuar. Não há atalho de pontuação para indicado.
- **Automático × manual:** ver §1.4 — misto no V1, canal a canal.
- **Aprovação:** não se aplica a esta etapa — é coleta, não decisão.
- **Histórico de tentativa anterior:** MSFE §10 já declara explicitamente o limite: "Classe A depende de sessão autenticada no LinkedIn para o critério mais forte (A1/A2). Sem isso, o peso migra para Glassdoor + Reclame Aqui, com perda de precisão" — ou seja, já sabemos, ANTES de construir, que a versão sem LinkedIn autenticado terá precisão reduzida. Isso não é um risco a descobrir depois — é um fato já registrado na metodologia-mãe.

### F-C · Pontuação (score Classe A/B/C + knockout Classe D)

- **Quem pode:** o sistema calcula; ninguém "pode" alterar manualmente o score sem justificativa registrada (senão o score perde credibilidade como "fato oponível").
- **Limite:** fórmula fechada da MSFE §7 — Classe A 45 + Classe B 30 + Classe C 25 = 100. `<55` descartado, `55-69` reserva, `≥70` avança.
- **Exceção:** **knockout de Classe D (§7 Etapa 1) sempre precede o score** — reprovou 1 knockout, elimina, não pontua, "sem exceção" (texto literal da MSFE). O sistema NUNCA deve permitir um gestor "forçar" um candidato eliminado por knockout a avançar sem revalidar o knockout em si — se o gestor discorda do knockout, a correção é no dado de evidência, não um override direto do resultado.
- **Automático × manual:** cálculo automático a partir de evidência coletada — mas Classe B (performativo, F3) inclui itens que só existem depois de uma interação humana (B1-B6, "embasamento legal", "acesso ao executor" etc.) — **o score final NUNCA é 100% calculável antes da fase F3 acontecer**. Isso significa que o "score" que chega no ClickUp na fase de mineração é PARCIAL (só Classe A + Classe C, no máximo 70 de 100) até o gestor completar F3.
- **Aprovação:** nenhuma — é cálculo, não decisão.
- **Histórico de tentativa anterior:** nenhum score foi calculado antes — não há precedente de erro a corrigir aqui, é o primeiro ciclo (MSFE §9.4, "baseline honesto").

### F-D · Sincronização com ClickUp (pipeline)

- **Quem pode:** o sistema cria/move cards; o gestor move manualmente também quando decide (mover é ação dupla — automática por regra OU manual por decisão do gestor).
- **Limite:** nenhum limite técnico conhecido — depende do plano ClickUp da conta e das capacidades reais do MCP disponível, **não verificadas nesta sessão** (ver Pergunta em Aberto, eixo Infra).
- **Exceção:** candidato eliminado por knockout NÃO necessariamente precisa virar card visível no pipeline principal — pode ir para uma lista "Eliminados" separada, para não poluir o funil ativo, mas SEM deixar de existir no dataset de calibração (MSFE §9.2 exige registrar rejeitados).
- **Automático × manual:** criação de card = automática, a partir da mineração; movimentação entre fases = decisão do gestor, manual (mesmo padrão do funil comercial existente, onde fases avançam por decisão do "SDR").
- **Aprovação:** não se aplica.
- **Histórico de tentativa anterior:** não existe pipeline de fornecedor no ClickUp hoje — mas existe um padrão irmão validado e funcionando (funil comercial `9011677992`, com automação n8n) a reaproveitar como referência técnica, não como pipeline compartilhado.

### F-E · Decisão do gestor por fase

- **Quem pode:** exclusivamente o gestor — em nenhuma fase o sistema decide sozinho se um candidato avança comercialmente (mesmo com score alto).
- **Limite:** nenhum — mas a MSFE já define os gates que restringem a decisão do gestor a "dentro das regras": ele pode eliminar antecipadamente (a qualquer momento, por qualquer motivo, inclusive subjetivo — é dele a decisão final), mas NÃO pode fazer um candidato "pular" F4 (análise de contrato) ou F5 (piloto pago) direto para contrato longo — esses dois gates são hard-blocked pela própria metodologia (MSFE §2, "Nenhuma fase é pulável").
- **Exceção:** se o pool secar (não há candidato com score ≥ 70), o gestor pode reabrir candidatos na faixa "reserva" (55-69) — já previsto na MSFE §7 Etapa 2.
- **Automático × manual:** 100% manual, por definição — é o núcleo do "processo seletivo" (analogia RH do FQF).
- **Aprovação:** a decisão do gestor de avançar para F4 é o gatilho que aciona `advogado-contratos` — não precisa aprovação de mais ninguém hoje (Julio é o único gestor confirmado).
- **Histórico de tentativa anterior:** o padrão histórico relatado é justamente a AUSÊNCIA de gate — decisão de contratar baseada em proposta/conversa, sem F1-F5 estruturados. Este módulo existe para nunca mais permitir esse atalho.

### F-F · Registro de piloto pago + medição pós-contratação (F5 MSFE + §8)

- **Quem pode:** gestor registra os dados de medição (data prometida × entregue, nº de idas e vindas, quem executou, manifestação proativa, demanda extra cobrada/absorvida — MSFE §8).
- **Limite:** MSFE define "1-2 competências reais" como escopo do piloto — o sistema não precisa suportar N competências arbitrárias no V1.
- **Exceção:** se o piloto não bater o prometido, elimina — SEM negociação de "mais uma chance" dentro do mesmo ciclo (MSFE §7 Etapa 4, "não bateu → elimina"). Reabrir esse mesmo fornecedor como candidato novo, mais tarde, é uma NOVA vaga, não uma exceção dentro da mesma.
- **Automático × manual:** registro manual (o gestor mede e digita); o SISTEMA pode calcular automaticamente se "data prometida × data entregue" bateu ou não, dado os dois valores.
- **Aprovação:** não se aplica.
- **Histórico de tentativa anterior:** nunca existiu piloto pago formal medido nas contratações anteriores relatadas — é item novo, não correção de algo que já rodava mal.

### F-G · Loop de calibração (MSFE §9)

- **Quem pode:** gestor conduz a retro de 4 perguntas (MSFE §9.3) ao encerrar cada contratação (bem ou mal sucedida).
- **Limite:** MSFE §9.5 já declara o limite estatístico — com poucas contratações/ano, não dá para calibrar peso por regressão, só por acúmulo de sinal. O sistema NÃO deve fingir rigor estatístico que a amostra não sustenta (mesma vedação da metodologia-mãe).
- **Exceção:** nenhuma — toda contratação encerrada (sucesso ou erro, conforme definição operacional MSFE §9.1) entra no dataset, incluindo candidatos REJEITADOS antes da contratação (grupo de controle, MSFE §9.2).
- **Automático × manual:** dataset alimentado automaticamente pelos dados já coletados nas fases anteriores (score, knockouts, resultado do piloto); a RETRO (as 4 perguntas) é sempre humana — é julgamento, não cálculo.
- **Aprovação:** não se aplica.
- **Histórico de tentativa anterior:** não existe — é a lacuna que a MSFE §9.4 batiza de "baseline desconhecido". Este módulo é o que torna o primeiro ciclo mensurável.

---

## 3 · FUNCIONALIDADES DETALHADAS (edge cases)

### F-A · Abrir vaga de fornecedor — edge cases

1. **E se o gestor abrir uma vaga para um tipo de fornecedor que não está na tabela MSFE §2.1** (ex: "consultoria de RH", que não é nenhum dos 7 tipos listados)? → o sistema não tem Bloco 6/Classe D para esse tipo. V1 deve bloquear ou forçar preenchimento manual do knockout específico — nunca inventar knockout genérico.
2. **E se duas vagas para o MESMO tipo de fornecedor (ex: contábil) forem abertas em paralelo** (ex: para duas empresas diferentes do grupo)? → mineração pode originar candidatos sobrepostos — o sistema deve reconhecer candidato já minerado antes (mesmo CNPJ) e reaproveitar a evidência já coletada, não minerar do zero de novo.
3. **E se o gestor abrir a vaga sem definir a camada MSFE §1.5** (contabilidade vs BPO vs CFOaaS vs fomento)? → sem camada definida, não há preço de referência para o gate C1 (compatibilidade preço×estrutura) — o sistema deve tornar esse campo obrigatório, não opcional.
4. **E se o escopo pedido pelo gestor abranger MÚLTIPLAS camadas ao mesmo tempo** (ex: quer um fornecedor que faça contabilidade E CFOaaS)? → MSFE §10 já avisa: "Não encontra fornecedor que não existe [...] a solução é dividir em 3-4 fornecedores, não flexibilizar o critério". O sistema deveria sinalizar esse mismatch na abertura da vaga, não deixar o gestor descobrir isso só depois de eliminar todo o pool.
5. **E se o gestor quiser cancelar/pausar uma vaga no meio do funil** (candidatos já minerados, mas a necessidade mudou)? → estado "pausada" precisa existir; candidatos já minerados não devem ser descartados (o trabalho de mineração tem custo e pode servir a uma vaga futura do mesmo tipo).

### F-B · Originação e mineração — edge cases

1. **E se o candidato tiver perfil de LinkedIn privado, incompleto ou deletado**? → não atinge o mínimo de 4 canais com esse canal — vira "dados insuficientes" (regra explícita MSFE §4), não deve ser forçado a pontuar com peso zerado disfarçado de score baixo.
2. **E se a mineração encontrar SÓ 3 canais em vez dos 4 mínimos**? → candidato explicitamente marcado "dados insuficientes", nunca aparece misturado com candidatos que pontuaram — a UI/pipeline precisa distinguir os dois estados.
3. **E se dois candidatos diferentes tiverem o MESMO sócio-fundador (empresas irmãs/holding do mesmo grupo)**? → viola a independência do pool — sinal a capturar e expor ao gestor (não eliminar automaticamente, mas alertar).
4. **E se um canal (ex: Reclame Aqui) estiver fora do ar ou mudar de estrutura de página no momento da mineração**? → falha de canal não deve derrubar a mineração inteira do candidato — precisa de tratamento de canal-a-canal com retry/fallback, e se persistir, contar como canal não coletado (afeta o gate dos 4 mínimos).
5. **E se o candidato mudar de razão social/CNPJ entre a mineração inicial e a fase de piloto** (rebranding, fusão)? → o sistema precisa reidentificar como o MESMO candidato (rastro de auditoria), não recomeçar do zero nem perder a evidência já coletada.
6. **E se a raspagem de LinkedIn (quando/se implementada) for bloqueada por rate-limit ou exigir 2FA por SMS no meio de uma sessão** (risco técnico já mapeado no briefing da tarefa)? → V1 não deve depender de automação persistente de LinkedIn funcionando sempre — precisa de fallback assistido por humano sem quebrar o funil inteiro (ver §5, decisão de V1 semi-manual).

### F-C · Pontuação — edge cases

1. **E se um candidato tiver score alto em Classe A e C mas ainda não passou por F3 (performativo)**? → o score exibido precisa deixar claro que é PARCIAL (máx. 70/100 possível), nunca apresentar como "70 = nota final" quando na verdade é "70 de um total que ainda vai crescer ou não".
2. **E se o gestor discordar de um knockout automático** (ex: acha que o critério foi aplicado errado para aquele caso)? → correção deve ser na EVIDÊNCIA (reabrir a checagem daquele knockout com dado novo), nunca um botão de "forçar aprovação" que ignora o knockout sem revalidação.
3. **E se duas fontes de evidência (ex: LinkedIn e formulário FQF) DIVERGIREM sobre o mesmo fato** (ex: headcount declarado 12, LinkedIn mostra 5)? → é achado automático da chave de leitura FQF (Parte II, seção A) — o sistema deve capturar e mostrar a divergência explicitamente ao gestor, não escolher uma fonte silenciosamente.
4. **E se o candidato responder o FQF com "não sei" no campo 2.6 (índice de prazo)**? → FQF já resolve isso explicitamente: "não sei" é resposta honesta e aceitável (classifica como Artesão), MAS um número inventado é PIOR que ausência de resposta — o sistema não deve tratar "não sei" como campo vazio penalizável do mesmo jeito que evasão.
5. **E se o candidato reprovar uma armadilha (ex: 9.4, oferecer Lei do Bem fora do Lucro Real)**? → é knockout de honestidade, não desconto de pontos — elimina, igual a um knockout de Classe D, mesmo estando tecnicamente no Bloco 9 (Transparência) do FQF.

### F-D · Sincronização com ClickUp — edge cases

1. **E se a criação automática de card falhar** (API do ClickUp fora do ar, rate limit, campo customizado não existe ainda no workspace)? → falha não pode ser silenciosa — candidato pontuado que nunca virou card visível é pior que não ter pontuado (gestor nem sabe que existe).
2. **E se o gestor mover um card manualmente PARA TRÁS no funil** (ex: de "F4 análise de contrato" de volta para "F1 mineração", porque precisa de mais evidência)? → precisa ser permitido — o funil não é estritamente unidirecional (MSFE não proíbe reabrir).
3. **E se dois candidatos concorrentes (mesma vaga) tiverem exatamente o mesmo score**? → sistema não deve forçar desempate automático — é decisão do gestor, mostrar ambos lado a lado.
4. **E se o campo customizado que guarda score/CTP no ClickUp for editado manualmente por alguém direto no ClickUp**, sem passar pelo sistema? → cria divergência entre a fonte de verdade real (§1.3) e o que o ClickUp mostra — risco a documentar na decisão de arquitetura, não a resolver aqui.
5. **E se o gestor quiser um candidato NO PIPELINE sem que ele tenha passado pela mineração automática** (indicação pessoal, MSFE já prevê isso em §2.1)? → precisa existir caminho de entrada manual de candidato no funil, que ainda assim é obrigado a cumprir o gate de 4 canais mínimos antes de pontuar.

### F-E · Decisão do gestor por fase — edge cases

1. **E se o gestor tentar aprovar um candidato para contrato longo sem passar por F4 (análise de contrato)**? → hard block da própria metodologia — o sistema deve impedir tecnicamente essa transição, não só avisar.
2. **E se `advogado-contratos` retornar NO-GO em F4, mas o gestor quiser prosseguir mesmo assim** (pressão de prazo, por exemplo)? → decisão dele — mas o sistema deve registrar essa decisão como uma EXCEÇÃO EXPLÍCITA carimbada (quem decidiu, quando, por quê), nunca deixar como se o gate tivesse sido cumprido normalmente.
3. **E se o pool inteiro for eliminado (nenhum candidato sobrevive aos knockouts)**? → MSFE §10 já prevê esse resultado como correto, não como falha do sistema — a UI precisa comunicar isso como "o mercado não tem quem atenda esse escopo dessa forma" (dividir em mais fornecedores), não como erro.
4. **E se o gestor demorar meses para decidir sobre um candidato parado numa fase**? → evidência coletada pode ficar desatualizada (ex: turnover do fornecedor mudou entre a mineração e a decisão) — precisa de sinalização de "evidência antiga, revalidar" após um prazo (a definir em SPEC).
5. **E se surgir um segundo gestor decidindo sobre a mesma vaga** (cenário só relevante se Hipótese B do §0.4 se confirmar)? → conflito de decisão simultânea — fora de escopo do V1 single-tenant, mas registrado aqui para não ser esquecido se o modelo de negócio virar B.

### F-F · Piloto pago + medição — edge cases

1. **E se o piloto for parcialmente bem-sucedido** (1 de 2 competências bateu o prometido)? → MSFE não prevê meio-termo explícito ("bateu → contrato longo; não bateu → elimina") — é uma pergunta em aberto real de regra de negócio, não coberta pela metodologia-mãe (registrar e levar de volta para quem mantém a MSFE, não decidir aqui).
2. **E se o fornecedor pedir para refazer a competência do piloto que falhou** (alegando mal-entendido de escopo)? → MSFE Cl. 6 (do modelo de contrato enxuto) já prevê refação sem remuneração adicional como padrão contratual — mas isso é sobre contrato já assinado; no piloto (pré-contrato longo) essa permissão não está definida — outra pergunta em aberto.
3. **E se o gestor não registrar a medição do piloto a tempo** (esquecer)? → sem registro, "não cumpriu" vira sensação, não fato oponível (MSFE §8) — o sistema deveria lembrar/cobrar o registro, não deixar como formulário opcional esquecível.
4. **E se o piloto envolver dado sensível do próprio grupo** (ex: acesso a sistema contábil real para o piloto)? → levanta requisito de segurança/NDA antes do piloto começar — não coberto pela MSFE (que assume que o piloto já é seguro de fazer), registrar como risco.
5. **E se o resultado do piloto for ambíguo por causa de uma falha do LADO do contratante** (ex: documentação não enviada a tempo, MSFE §4.3 do FQF prevê isso do lado do fornecedor mas o inverso — falha do cliente — também acontece)? → medição precisa distinguir atraso causado pelo fornecedor de atraso causado pelo próprio grupo, senão o dado de calibração fica poluído.

### F-G · Loop de calibração — edge cases

1. **E se uma contratação nunca for formalmente "encerrada"** (nem sucesso nem fracasso declarado, só vai continuando)? → MSFE §9.1 define erro por 3 condições objetivas — mas não define quando uma contratação BEM-SUCEDIDA "conta" para o dataset (12 meses? 24 meses?). Pergunta em aberto herdada da própria metodologia-mãe.
2. **E se o dataset tiver poucas linhas (N pequeno) e um gestor tentar tirar conclusão estatística indevida dele**? → MSFE §9.5 já veda isso explicitamente ("fingir precisão estatística aqui seria falso rigor") — o sistema não deve exibir gráfico/percentual de acurácia enganosamente preciso com poucos casos.
3. **E se um critério "aposentado" (MSFE §9.3, pergunta 2) for reintroduzido depois, por um caso novo que o revalida**? → versionamento de critério precisa suportar isso (v1.1 → v1.2 → volta a usar algo da v1.0) sem perder o histórico de por que foi aposentado antes.

---

## 4 · JORNADA DO GESTOR

Régua obrigatória: **é intuitivo sem alguém explicar do lado?**

1. **Descoberta** — o gestor já vive a dor (relatada, real, recorrente). Não há "descoberta" de necessidade — ele já sabe que precisa disso. O risco de UX aqui não é convencer, é não decepcionar: se a primeira vaga aberta minerar mal (poucos candidatos, canais falhando), a confiança cai imediatamente, porque ele já foi traído por processo malfeito antes.
2. **Primeiro uso** — abrir a primeira vaga. Precisa ser óbvio que campo obrigatório é "tipo de fornecedor" + "camada" (§F-A) — sem isso o sistema não sabe qual critério aplicar. Se a UI pedir isso de forma genérica ("descreva o que você precisa"), o gestor vai escrever texto livre e o sistema não vai conseguir mapear para o Bloco 6 certo — **a régua de "intuitivo" aqui é: o formulário de abertura de vaga tem que guiar para uma das 7 categorias da MSFE §2.1, não aceitar texto livre sem categorização**.
3. **Uso recorrente** — candidatos chegam pontuados no pipeline; o gestor decide fase a fase dentro do ClickUp (ambiente que ele já usa no dia a dia para o funil comercial, reduz curva de aprendizado). O ritmo esperado é baixo-volume/alta-importância (não é um funil de centenas de itens por dia, é 1 vaga por vez, poucas vezes por ano) — a UX não deve ser otimizada para volume, e sim para CONFIANÇA na evidência (cada score precisa estar sempre a 1 clique da fonte que o gerou).
4. **Erro/exceção** — pool inteiro eliminado (edge case F-E.3), knockout que o gestor discorda, piloto ambíguo (F-F.1) — todos precisam de caminho claro de "isso é esperado, aqui está o porquê" em vez do gestor achar que o sistema quebrou.

---

## 5 · ROADMAP EVOLUTIVO — V1 / V2 / V3+

### V1 — menor recorte que prova a hipótese central

**Hipótese central a provar:** um funil estruturado com evidência de terceiro (não declaração) reduz erro de contratação de fornecedor, mesmo sem 100% de automação.

**Decisão de design deliberada:** **V1 é semi-manual, não 100% automático.** Justificativa:
- O bloqueio de LinkedIn (sessão autenticada, MSFE §4/§10) é real e não tem solução simples confirmada nesta sessão — construir a V1 apostando em raspagem automática confiável de LinkedIn é apostar num risco técnico não resolvido.
- Volume esperado é baixo (poucas contratações estratégicas por ano, MSFE §9.5) — o ganho de automatizar 100% a mineração não compensa o custo de engenharia se o gestor só abre 2-3 vagas por ano. Automação total é otimização prematura para este volume.
- A MSFE §10 já admite que sem LinkedIn autenticado "o peso migra para Glassdoor + Reclame Aqui, com perda de precisão" — ou seja, a metodologia-mãe já projetou operar com essa limitação. O produto pode nascer no mesmo nível de precisão que a metodologia já assume como aceitável.

**Escopo V1 (IN):**
- Abrir vaga (tipo + camada + escopo) — F-A completo.
- Mineração ASSISTIDA: sistema guia o gestor/analista por um checklist dos canais públicos (Glassdoor, Reclame Aqui, Google Reviews, Instagram, Reddit via navegador — todos sem bloqueio de login conhecido) + campo manual para colar o achado do LinkedIn quando checado manualmente. Não há scraper automático de LinkedIn no V1.
- Knockouts de Classe D (Bloco 6 FQF) e gate C1 — automatizáveis por regra fechada, entram desde o V1.
- Cálculo de score (Classe A/B/C) a partir do que foi coletado — automático, mesmo que a coleta em si seja assistida.
- Sincronização com ClickUp: criação de card automática por candidato aprovado, campos customizados com score/canais/knockouts.
- Registro de piloto (F-F) e das 5 perguntas da MSFE §8 dentro do card.
- FQF (formulário) enviado e cruzado manualmente no V1 — sem envio/recebimento automatizado ainda.

**Escopo V1 (OUT — fica para depois, sem travar o valor central):**
- Automação de raspagem persistente de LinkedIn.
- Envio automático do FQF por e-mail/formulário digital com prazo cronometrado.
- Dashboard de calibração com visualização estatística (MSFE §9) — no V1, calibração é retro manual documentada, não dashboard.
- Multi-tenant / múltiplos gestores simultâneos (Hipótese B, §0.4) — se confirmado que o produto é vendável, entra como V2/V3, não trava o V1 interno.
- Integração automática `advogado-contratos` ↔ card ClickUp (V1: o veredito é colado manualmente no card).

### V2

- Envio e recebimento digital do FQF, com prazo cronometrado automaticamente (o prazo de resposta É parte do teste comportamental, FQF Parte I — cronometrar automaticamente aumenta a precisão do sinal B4).
- Automação de mineração para os canais que não exigem login (Glassdoor, Reclame Aqui, Google Reviews, Instagram, Reddit) — reduzindo trabalho manual, mantendo LinkedIn manual/assistido.
- Se Hipótese B (§0.4) confirmada: multi-tenant básico.
- Dashboard simples do dataset de calibração (MSFE §9.2) — visão tabular, sem pretensão estatística ainda (respeitando §9.5).

### V3+

- Reavaliar automação de LinkedIn (só se um caminho legal/técnico confiável surgir — ver Pergunta em Aberto).
- Calibração de peso mais sofisticada, SE o volume de contratações acumuladas justificar (MSFE §9.5 — condicional ao N crescer, não uma meta fixa de data).
- Integração completa com `advogado-contratos` (F4 automatizado ponta a ponta) e com os agentes de mineração/estratégia (`prospector-fornecedor-qualificado`, `estrategista-sourcing-fornecedor-estrategico`) quando esses passarem por Discovery própria.

---

## PERGUNTAS EM ABERTO (por eixo — precisam de decisão do stakeholder antes de SPEC)

### Eixo Escopo / Modelo de negócio
1. O módulo é ferramenta interna do grupo (KTANA/CSB/EI) ou módulo vendável do Empresa Inteligente OS (Hipótese A vs B, §0.4)? Isso determina se é single-tenant ou multi-tenant desde o V1.
2. Porte/nº de empresas do grupo que vão usar isso hoje, UFs de operação e regimes tributários — necessário para saber quais knockouts de Classe D (multi-estado, COSIF, regime) realmente se aplicam ao primeiro caso de uso.

### Eixo Volume / Calibração
3. Volume esperado de contratações de fornecedor estratégico por ano — define se a automação pesada (V2/V3) se justifica e em que prazo, e há quanto tempo até o dataset de calibração (MSFE §9) ter massa mínima útil.

### Eixo Infraestrutura / ClickUp
4. Qual workspace/space do ClickUp recebe o pipeline de fornecedor — reaproveitar o workspace `9011677992` (já usado pro funil comercial, achado real nesta sessão) numa Lista separada, ou workspace novo dedicado? E quais operações reais o MCP ClickUp disponível suporta (criar lista/pasta, campo customizado, mover status via automação) — **não verificado nesta sessão** (ferramenta ClickUp não estava disponível neste ambiente de Discovery), precisa ser confirmado antes da SPEC.
5. Onde o módulo roda tecnicamente, isolado da zona protegida do site de marketing (§1.5.4, §1.6) — decisão de arquitetura pendente de um `arquiteto`/`cto` especialista, fora do escopo deste Discovery de produto.

### Eixo Automação / Legal
6. Postura sobre automação de raspagem em canais com ToS restritivo (LinkedIn em especial) — aceitar operar permanentemente em modo assistido/manual (recomendação deste Discovery para o V1, §5), ou investir em resolver esse bloqueio tecnicamente/legalmente mais cedo?

### Eixo LGPD / Jurídico
7. Base legal e tratamento adequado para mineração de dado de pessoa física de terceiro (nome de analista, depoimento de ex-funcionário) — **este Discovery não substitui validação jurídica formal**. Ver "Especialistas complementares necessários" abaixo.

### Eixo Regra de negócio herdada da MSFE (não resolvida na metodologia-mãe, aparece aqui)
8. Piloto parcialmente bem-sucedido (F-F edge case 1) — a MSFE só define os extremos "bateu/não bateu". Precisa de regra de meio-termo, decisão que cabe a quem mantém a metodologia (mesmo dono da MSFE/FQF), não a este Discovery de produto.
9. Refação de competência reprovada no piloto (F-F edge case 2) — permitida ou não antes do contrato longo?
10. Quando uma contratação bem-sucedida "conta" oficialmente para o dataset de calibração (F-G edge case 1) — 12 ou 24 meses de sobrevivência?

---

## ESPECIALISTAS COMPLEMENTARES NECESSÁRIOS ANTES DA FASE DE SPEC

Este Discovery de produto NÃO é suficiente sozinho para autorizar a construção — os seguintes eixos precisam de validação por especialista antes da SPEC (FASE 1), por exigência explícita de `~/.claude/rules/discovery-metodologia-padrao-obrigatoria.md` e do princípio zero deste agente:

- **Jurídico/LGPD** — validar a base legal de mineração de dado de pessoa física de terceiro (pergunta 7).
- **Arquiteto/CTO** — decidir onde o módulo roda (pergunta 5), e a decisão banco-próprio-vs-ClickUp-como-fonte-de-verdade (§1.3).
- **Discovery de agente separado** (via `especialista-discovery-agentes`) — para os dois agentes já citados na MSFE §12 (`estrategista-sourcing-fornecedor-estrategico`, `prospector-fornecedor-qualificado`), que executariam de fato F0/F1/F2/F4/F5 quando o módulo evoluir além do V1 assistido.
- **Dono da metodologia MSFE/FQF** (Julio, provavelmente com o mesmo squad que produziu os dois documentos-base) — para fechar as perguntas 8-10, que são lacunas da PRÓPRIA metodologia, não deste Discovery de produto.

---

**Path:** `~/empresa-inteligente/docs/discovery/2026-08-06-recrutamento-fornecedor-discovery-v1.md`
**Aplicável:** módulo "Recrutamento de Fornecedor", produto Empresa Inteligente OS
**Fonte:** Julio (falha real de contratação relatada ao vivo) + MSFE v1.0 + FQF v1.1 + pré-flight real do repo `empresa-inteligente` + Notion (workspace ClickUp `9011677992` do funil comercial existente)
