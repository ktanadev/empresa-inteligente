# SPEC VISUAL · Recrutamento de Fornecedor · Empresa Inteligente OS · 2026-08-06 · v1

**Insumo:** `~/empresa-inteligente/docs/discovery/2026-08-06-recrutamento-fornecedor-discovery-v1.md`
**Metodologia operacionalizada:** MSFE v1.0 + FQF v1.1 (`~/csb-war-room/docs/metodologias/`)
**Natureza do artefato:** ferramenta de gestão (UI operável, escaneada e trabalhada todo dia), não landing page. Nenhum padrão de marketing do repo (hero grande, ticker, pricing glossy, CTA pill em tudo) é herdado por padrão — só o que serve a uma UI densa é reaproveitado, e cada reaproveitamento cita a fonte.
**Escopo:** define layout, tokens, componentes e estados. **Não implementa HTML** — isso é do `engenheiro-frontend`, próximo elo do pipeline (`padrao-prototipagem-squad-cross-projeto.md`).

---

## 1 · EXTRAÇÃO DA IDENTIDADE EXISTENTE (com arquivo:linha)

Confirmado que **não existe design system formal** neste repo (`~/empresa-inteligente/docs/discovery/...md:48` — "sem `design-system/` ou `_shared/`"). O que existe são 2 camadas de token, ambas de marketing, com valores próximos mas não idênticos:

| Token | `niche.css` | `index.html` (`<style>` inline) |
|---|---|---|
| Vermelho de marca | `--red:#D70030` — `niche.css:3` | `--red:#D70030` — `index.html:182` (idêntico) |
| Vermelho escuro/hover | *(não existe)* | `--red-dark:#B0002A` — `index.html:183` |
| Preto/tinta | `--black:#1D1D1F` — `niche.css:3` | `--black:#1C1C1C` — `index.html:184` (0,05% de diferença, provavelmente drift entre sessões de edição) |
| Cinza texto | `--gray:#86868B` — `niche.css:3` | `--gray-text:#6B7280` — `index.html:188` (mais escuro/saturado que o de `niche.css`) |
| Fundo neutro | `--light-gray:#F5F5F7` — `niche.css:3` | `--gray-bg:#F4F4F4` — `index.html:185` |
| Borda | *(não existe token dedicado)* | `--gray-border:#E5E5E5` — `index.html:188` |
| Fonte display/logo | `'Zen Dots'` — `niche.css:16` (`.ei-logo`), `niche.css:132` (`.ei-dif-num`) | `'Space Grotesk'` — `index.html:193` (`--font-display`) |
| Fonte corpo | `'Inter'` — `niche.css:5` | `'Satoshi','Inter'` — `index.html:194` (`--font-body`) |
| Fonte mono | *(não existe)* | `'JetBrains Mono'` — `index.html:195` (`--font-mono`) |
| Fonte editorial/itálico | *(não existe)* | `'IBM Plex Sans'` — `index.html:196` (`--font-editorial`, usado em subtítulos itálicos) |
| Raio de cartão | `20px` — `niche.css:70,113,131` (`.ei-tipo-card`, `.ei-dept-card`, `.ei-dif-card`) | idêntico, `20px` em vários seletores |
| Raio de botão | `980px` (pill) — `niche.css:32` (`.btn-red`) | idêntico em `.btn-primary`, `.price-btn` |
| CDN de fonte | `fonts.googleapis.com` — `niche.css` carregado via `<link>` na página que o consome, ex. `contabilidade/index.html:19` | `fonts.googleapis.com` + `api.fontshare.com` — `index.html:44-47` |
| Ícones | *(inline SVG só)* | Lucide via CDN `unpkg.com` — `index.html:48` |

**Achado não usado, registrado por honestidade:** `index.html:197-204` declara um SEGUNDO fragmento de tokens, autodenominado `/* Design System — Ktana White v1.0 */`, com `--ink:#0B0B0C --paper:#FEFEF6 --accent:#A01E24 --accent-lo:#E5433A --accent-hi:#4A0E12 --accent-grad:...`. Não encontrei esse fragmento aplicado em nenhum seletor lido do arquivo (`--red:#D70030` é o que de fato pinta CTA/hero/pricing). Não adoto esse fragmento como base — cito porque **um valor dele foi reaproveitado abaixo** (`--ink:#0B0B0C`, §2.1) por ser um near-black de boa qualidade, não por ser "o sistema oficial" (não é, está inerte no código-fonte).

### O que NÃO herdo desta identidade, e por quê

- **CDN de fonte (Google Fonts/Fontshare/unpkg).** O briefing desta spec é explícito: CSP bloqueia CDN de fonte no serviço que vai hospedar esta ferramenta (que nasce fora da árvore pública por exigência do próprio Discovery, `...discovery-v1.md:143` "não deve nascer dentro da árvore servida como `empresainteligente.ai/` público"). Zen Dots/Space Grotesk/Satoshi/IBM Plex Sans não têm licença de embutir localmente confirmada nesta sessão — troco por font-stacks de sistema (§2.3), preservando peso/tracking como o que carrega a identidade, não o glifo exato da fonte.
- **Raio de botão pill (`980px`) em tudo.** Funciona para CTA de conversão numa LP. Numa ferramenta densa, pill-em-tudo acaba borrando a hierarquia entre "isto é uma ação" e "isto é um rótulo". Mantenho pill **só** para badge de status (onde "cápsula" já é convenção de estado), raio menor para botão/input/card (§2.5).
- **Hero, ticker, pricing, glow/gradiente decorativo, grão de textura.** Nenhum desses padrões existe para orientar decisão operacional — existem para converter visitante. Zero herança.
- **`--gray-text:#6B7280` de `index.html`.** Uso `--gray:#86868B` de `niche.css` como base da escala neutra (é o valor citado 2× de forma consistente, inclusive no fato já documentado em `~/.claude/rules/ktana-rules.md` como paleta-irmã KTANA), e derivo um tom mais escuro que ele especificamente para texto secundário em fundo claro, onde a exigência de contraste é mais severa que a de um subtítulo de marketing.

---

## 2 · SISTEMA DE TOKENS

Arquivo alvo do `engenheiro-frontend`: `tokens.css`, consumido via `var(--token)` — nunca hex literal, por `~/.claude/rules/csb-design-pre-flight.md`/`orquestrador-governance.md` (mesmo fora do domínio CSB, é o mesmo princípio geral já em vigor em todo o ecossistema).

### 2.1 · Cor — primitivos neutros

Escala derivada dos 3 pontos reais que o repo tem (`--red`, `--black`, `--gray`, `--light-gray`) mais os degraus intermediários que uma UI densa exige e a LP nunca precisou ter.

```css
:root {
  --neutral-0:   #FFFFFF;                 /* --white, niche.css:3 */
  --neutral-50:  #F5F5F7;                 /* --light-gray, niche.css:3 */
  --neutral-100: #EDEDF0;                 /* derivado */
  --neutral-200: #E2E2E6;                 /* derivado, próximo de --gray-border index.html:188 */
  --neutral-300: #C7C7CC;                 /* derivado */
  --neutral-400: #ADADB3;                 /* derivado */
  --neutral-500: #86868B;                 /* --gray, niche.css:3 */
  --neutral-600: #68686D;                 /* derivado — mínimo p/ texto secundário AA em fundo branco */
  --neutral-700: #4A4A4E;                 /* derivado */
  --neutral-800: #2C2C2E;                 /* derivado */
  --neutral-900: #1C1C1E;                 /* canonizado de --black (#1D1D1F niche.css:3 / #1C1C1C index.html:184) */
  --neutral-950: #0B0B0C;                 /* reaproveitado de index.html:198 (--ink, fragmento inerte) */
}
```

### 2.2 · Cor — marca (uso restrito: ação primária, foco, marca — nunca estado)

```css
:root {
  --brand:       #D70030;  /* niche.css:3 / index.html:182 */
  --brand-hover: #B0002A;  /* index.html:183 */
  --brand-tint:  #FDE7ED;  /* derivado, 8% de --brand sobre branco — fundo de badge de marca, não de estado */
}
```

### 2.3 · Cor — semântica de evidência (NOVA, não existe no repo — é o coração desta spec)

O princípio reitor da MSFE (`§0`, "declaração pesa zero") só vira interface se os 4 estados forem visualmente inconfundíveis entre si **e** com `--brand`. Por isso nenhuma cor de estado é derivada de `--brand` — são 4 famílias de matiz totalmente distintas, cada uma sempre acompanhada de ícone + rótulo textual (nunca só cor, requisito WCAG 1.4.1).

```css
:root {
  /* Verificado — evidência de terceiro confirmada. Conta pro score. */
  --state-verified:      #1F8A54;
  --state-verified-tint: #E7F6ED;
  --state-verified-line: #A9DDBE;

  /* Declarado — só o fornecedor disse. Nunca pontua sozinho. */
  --state-declared:      var(--neutral-500);
  --state-declared-tint: var(--neutral-100);
  --state-declared-line: var(--neutral-300);

  /* Divergente — declarado ≠ verificado. O achado mais valioso da tela. */
  --state-divergent:      #B45309;
  --state-divergent-tint: #FDF0DD;
  --state-divergent-line: #F3CC8F;

  /* Não coletado — ainda sem fonte. Não pontua, não é erro. */
  --state-uncollected:      var(--neutral-400);
  --state-uncollected-tint: transparent; /* tratamento tracejado, nunca preenchido — ver §4 */
  --state-uncollected-line: var(--neutral-300);

  /* Eliminado por knockout — deliberadamente NÃO é --brand. Hue e tom diferentes. */
  --state-eliminated:      #A02B1F;
  --state-eliminated-tint: #FBE7E4;
  --state-eliminated-line: #E2A79E;
}
```

**Por que `--state-eliminated` não é `--brand`:** `#D70030` é magenta-carmesim saturado (HSL ~338°); `#A02B1F` é vermelho-tijolo (HSL ~5°). 33° de diferença de matiz + queda de saturação — perceptível mesmo em daltonismo protanope/deuteranope moderado, e nunca aparecem lado a lado sem rótulo (todo badge tem ícone `✕`/`—` fixo, cor é reforço, não é o sinal único).

### 2.4 · Cor — classes de score (A/B/C), neutras de propósito

As barras de decomposição de score usam a escala de tinta (não hue), pra não competir visualmente com os 4 estados de evidência acima — eles são o que o olho deve caçar primeiro.

```css
:root {
  --class-a: var(--neutral-900); /* peso 45 — evidência de terceiro, o mais pesado */
  --class-b: var(--neutral-600); /* peso 30 — performativo */
  --class-c: var(--neutral-300); /* peso 25 — estrutural */
}
```

### 2.5 · Tipografia — font-stacks de sistema (substituindo Zen Dots/Space Grotesk/Satoshi por exigência de CSP, §1)

```css
:root {
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --font-mono: ui-monospace, "SF Mono", "Cascadia Mono", "Consolas", "Liberation Mono", monospace;
}
```

Uma única família sans para display e corpo — diferenciação é por peso/tamanho/tracking, não por trocar de fonte (a LP usa 4 famílias porque é uma peça de conversão; a ferramenta não precisa dessa variedade, e cada font-family a mais é uma dependência de carregamento que este produto — CSP-restrito — não tem como pagar de graça).

| Token | Peso | Tamanho | Tracking | Uso |
|---|---|---|---|---|
| `--text-display-lg` | 800 | 32px / 1.15 | -0.02em | Score composto (número grande, tela de candidato) |
| `--text-display-md` | 700 | 24px / 1.2 | -0.015em | Título de tela |
| `--text-heading` | 700 | 18px / 1.3 | -0.01em | Título de seção/card |
| `--text-body-lg` | 500 | 15px / 1.5 | normal | Corpo principal |
| `--text-body` | 400 | 14px / 1.5 | normal | Corpo padrão, linhas de tabela |
| `--text-label` | 600 | 12px / 1.3 | 0.04em, uppercase | Rótulo de campo/coluna |
| `--text-caption` | 500 | 11px / 1.4 | 0.02em | Metadado, timestamp, fonte da evidência |
| `--text-mono-lg` | 600 | 20px / 1.1 | normal, `font-variant-numeric: tabular-nums` | CTP, valores monetários grandes |
| `--text-mono` | 500 | 13px / 1.4 | normal, `font-variant-numeric: tabular-nums` | Score decomposto, percentuais, datas comparadas |

### 2.6 · Espaçamento — base 4px

```
--sp-1:4px  --sp-2:8px  --sp-3:12px  --sp-4:16px  --sp-5:20px  --sp-6:24px
--sp-8:32px --sp-10:40px --sp-12:48px --sp-16:64px
```

Densidade deliberadamente menor que a LP (que usa 80–100px de padding de seção, `niche.css:61,67,111`) — ferramenta de gestão é escaneada, não rolada como editorial.

### 2.7 · Raio — reduzido frente à LP, pill reservado a estado

```
--radius-xs: 4px   /* input, chip pequeno */
--radius-sm: 6px   /* badge de estado */
--radius-md: 8px   /* card, botão, select */
--radius-lg: 12px  /* painel, modal */
--radius-pill: 999px /* SÓ badge de status/fase — nunca botão de ação primária */
```

Diverge deliberadamente de `niche.css:32,70` (pill em botão, 20px em card) — ver §5.

### 2.8 · Sombra — sutil, dado denso não pede glow

```
--shadow-xs: 0 1px 2px rgba(11,11,12,.06)
--shadow-sm: 0 1px 3px rgba(11,11,12,.08), 0 1px 2px rgba(11,11,12,.04)
--shadow-md: 0 4px 12px rgba(11,11,12,.08)
```

### 2.9 · Tema claro (padrão) e escuro — tokens semânticos

```css
:root, :root[data-theme="light"] {
  --bg-canvas:    var(--neutral-50);
  --bg-surface:   var(--neutral-0);
  --bg-surface-2: var(--neutral-100);
  --border:       var(--neutral-200);
  --border-strong: var(--neutral-300);
  --text-primary:   var(--neutral-900);
  --text-secondary: var(--neutral-600);
  --text-tertiary:  var(--neutral-500);
  --text-inverse:   var(--neutral-0);
  --focus-ring: var(--brand);
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg-canvas:    var(--neutral-950);
    --bg-surface:   #17181C;
    --bg-surface-2: #1F2024;
    --border:       #2C2D31;
    --border-strong: #3A3B40;
    --text-primary:   var(--neutral-0);
    --text-secondary: var(--neutral-400);
    --text-tertiary:  var(--neutral-500);
    --text-inverse:   var(--neutral-900);
  }
}

:root[data-theme="dark"] {
  --bg-canvas:    var(--neutral-950);
  --bg-surface:   #17181C;
  --bg-surface-2: #1F2024;
  --border:       #2C2D31;
  --border-strong: #3A3B40;
  --text-primary:   var(--neutral-0);
  --text-secondary: var(--neutral-400);
  --text-tertiary:  var(--neutral-500);
  --text-inverse:   var(--neutral-900);
}
```

`data-theme` no `<html>`, alternável por toggle — vence a media query nos dois sentidos (usuário pode forçar claro com SO em dark, e vice-versa). Tokens de estado/marca (§2.2–2.4) **não mudam entre temas** — só os tints em fundo escuro precisam de opacidade reduzida em vez de tint sólido claro (`color-mix(in srgb, var(--state-verified) 18%, transparent)` no lugar de `--state-verified-tint` quando `data-theme="dark"`; documentar essa regra de troca no CSS do engenheiro, não recalcular hex por estado à mão).

---

## 3 · GRID E BREAKPOINTS (comum às 5 telas)

| Breakpoint | Largura | Layout |
|---|---|---|
| Desktop | ≥1440px | canvas de trabalho padrão — sidebar fixa 240px + conteúdo fluido, tabelas/kanban em colunas completas |
| Laptop | 1024–1439px | sidebar colapsável (ícone), conteúdo com scroll horizontal em tabelas largas (Tela 5) |
| Tablet | 768–1023px | sidebar vira drawer, kanban vira lista por fase com seletor de fase no topo, comparativo (Tela 5) empilha 2 candidatos por vez |
| Mobile | 375–767px | somente leitura operacional: ver pipeline, ver detalhe de candidato, decidir (botões grandes) — abrir vaga e mineração assistida (Telas 1 e 4, que exigem digitação extensa) são desencorajadas mas não bloqueadas, com aviso "melhor experiência no desktop" |

Container máximo de conteúdo: 1280px, `margin-inline:auto`, padding lateral `--sp-6` (desktop) / `--sp-4` (mobile).

---

## 4 · TELA A TELA

### Tela 1 · Abrir vaga de fornecedor

**Layout:** wizard de 4 passos (não formulário monolítico — Discovery §4.2/§4 "jornada do gestor" exige isso explicitamente: "o formulário de abertura de vaga tem que guiar para uma das 7 categorias da MSFE §2.1, não aceitar texto livre sem categorização"). Stepper horizontal fixo no topo (desktop/laptop), vertical colapsado em tablet/mobile.

1. **Tipo de fornecedor** — 7 cards de seleção única (rádio visual, não dropdown): Contábil/BPO/CFOaaS · Jurídico · Fomento · TI · Marketing · Insumo/Logística · Consultoria (MSFE §2.1). Cada card: ícone + nome + 1 linha de exemplo. Seleção destaca borda `--brand` + fundo `--brand-tint`.
2. **Camada** (só aparece se tipo = Contábil/BPO/CFOaaS) — segmented control de 4 opções (Contabilidade · BPO Financeiro · CFOaaS · Fomento, MSFE §1.5), com tooltip de preço de referência por camada. Se o gestor tentar marcar mais de uma camada como necessária no mesmo pedido (campo "abrange múltiplas camadas?" — edge case F-A.4), banner de aviso inline, cor `--state-divergent` (é um alerta, não um erro): *"A MSFE recomenda dividir em fornecedores separados quando o escopo cruza camadas — considere abrir vagas distintas."* Não bloqueia, só avisa.
3. **Escopo e knockouts aplicáveis** — textarea curta (limite visual ~280 caracteres, não é campo de redação livre longa) + lista de knockouts de Classe D pré-carregados pelo tipo escolhido (somente leitura nesta tela, edição fica na Tela 4/3). Se tipo não mapeado na tabela MSFE §2.1 (edge case F-A.1), bloqueia avanço com CTA "definir knockout manual" em vez de inventar categoria.
4. **CTP-alvo e revisão** — campo numérico BRL com `font-variant-numeric: tabular-nums`, tooltip explicando as 6 parcelas do CTP (MSFE §1.6) ao lado do label, não escondido em modal. Resumo de revisão (read-only) dos passos 1–3 antes do botão final "Abrir vaga".

**Componentes:** `SupplierTypeCard`, `ServiceLayerSelector`, `Stepper`, `WarningBanner`, `CTPField`, `Tooltip`.

**Estados:**
- Vazio (nenhuma vaga aberta ainda no workspace) — não é estado desta tela, é o estado inicial da Tela 2 antes de qualquer vaga existir; a partir daqui é sempre "criando".
- Erro de validação — campo obrigatório (tipo, camada quando aplicável) não preenchido: impede avanço do stepper, mensagem inline abaixo do campo, nunca só bordas vermelhas sem texto.
- Sucesso — vaga criada, redireciona para Tela 2 com a vaga nova já filtrada/destacada.

---

### Tela 2 · Pipeline / funil

**Layout:** Kanban horizontal, 1 coluna por fase, mais 1 lista lateral colapsada "Eliminados" (nunca deletados — Discovery F-D edge case 1, dataset de calibração precisa dos rejeitados).

**Colunas (mapeando MSFE §2 direto):**
`Originação (F-1)` → `Mineração (F1)` → `Aguardando Performativo` (score parcial calculado, ≤70 possível, esperando F3) → `Prova Performativa (F3)` → `Análise de Contrato (F4)` → `Piloto Pago (F5)` → `Contrato Longo`

Cada card (`CandidateCard`): nome do fornecedor, tag tipo/camada, chip de score (com badge "PARCIAL" se ainda não passou por F3), mini-cluster de 4 pontinhos coloridos (verificado/declarado/divergente/não-coletado — resumo visual do estado de evidência sem abrir o card), CTP estimado em mono, flag de "evidência desatingida — revalidar" (`StaleEvidenceFlag`, ícone relógio, `--state-divergent`) se a última coleta passou do prazo definido em SPEC técnica, indicação "Indicação pessoal" quando aplicável (F-B edge case, entrou sem originação automática mas ainda sujeito ao gate de 4 canais).

**Filtros no topo:** por vaga aberta, por tipo de fornecedor, toggle "mostrar dados insuficientes".

**Movimentação:** drag-and-drop entre fases é permitido nos dois sentidos (voltar fase é ação válida, Discovery F-D edge case 2 — "precisa de mais evidência").

**Estados:**
- Vazio — nenhuma vaga aberta: ilustração simples + CTA "Abrir vaga de fornecedor" (leva à Tela 1).
- Carregando — skeleton de cards (3 por coluna), nunca spinner de tela cheia (a informação de outras colunas continua útil enquanto uma sincroniza).
- Erro — falha de sincronização com o pipeline (ex.: candidato pontuado que não virou card): banner persistente no topo, vermelho `--state-eliminated`-adjacent mas rotulado como erro de sistema, não de dado (`"3 candidatos pontuados não sincronizaram — tentar novamente"`), nunca falha silenciosa (Discovery F-D edge case 1 é explícito: silêncio aqui é pior que não ter pontuado).
- Empate — dois candidatos com mesmo score na mesma coluna: sem desempate automático, ambos aparecem lado a lado sem hierarquia visual forçada entre eles (decisão fica pra Tela 5).

---

### Tela 3 · Candidato — detalhe e pontuação (tela mais importante do módulo)

**Layout (desktop):** header fixo + 2 colunas — esquerda (65%) evidência por classe, direita (35%, sticky) resumo de score e ações de gate.

**Header:** nome do fornecedor, CNPJ, tag tipo/camada, badge "Indicação pessoal" se aplicável, tag de fase atual do funil.

**Banner de knockout (Classe D), topo, sempre visível se algum item foi avaliado:**
Se **algum** knockout reprovado → banner cheio `--state-eliminated-tint`/`--state-eliminated`, `"ELIMINADO — reprovou [critério D2: multi-estado]"`, e o resto da tela (score, evidência) fica com opacidade reduzida mas **não escondido** — o gestor pode ver por que reprovou sem precisar navegar pra outro lugar. Se o gestor discorda de um knockout (edge case F-C.2), o botão disponível é *"Reabrir checagem deste critério com novo dado"* — nunca um botão de "forçar aprovação".

**Painel de score (coluna direita, sticky):**
- Número composto grande (`--text-display-lg`, mono, tabular): `72` sobre `100` — se Classe B ainda não coletada (pré-F3), badge amarelo `PARCIAL — máx. possível hoje: 70/100` ao lado do número (edge case F-C.1, nunca apresentar parcial como final).
- Barra decomposta horizontal empilhada: segmento A (peso 45, `--class-a`) + B (peso 30, `--class-b`, hachurado/pontilhado se ainda não coletado) + C (peso 25, `--class-c`), com valor numérico dentro/ao lado de cada segmento.
- Faixa de decisão (MSFE §7): `<55 descartado` / `55–69 reserva` / `≥70 avança` — indicador de onde o score atual cai, sempre visível mesmo em estado parcial (com aviso "pode mudar quando F3 completar").
- Botões de decisão do gestor: `Avançar fase` / `Marcar reserva` / `Eliminar` (com campo de motivo obrigatório) — sempre habilitados exceto quando bloqueado por knockout/hard-gate (edge case F-E.1: não deixa pular F4/F5, botão de avanço direto pra "Contrato longo" fica desabilitado com tooltip explicando o motivo até F4 e F5 estarem completos).

**Corpo — evidência por classe (abas ou seções empilhadas, uma por classe: A · B · C):**

Cada critério (ex. A1 Turnover, B1 Embasamento legal, C1 Compatibilidade preço×estrutura) é uma linha/`EvidenceRow`:
`[EvidenceStateBadge] Nome do critério — valor coletado — fonte (link clicável) — data da coleta`

**Painel de cruzamento declarado × verificado** (seção própria, não misturada nas linhas de evidência — é o achado mais valioso, precisa de destaque próprio, per Discovery §F-C edge case 3): tabela com colunas `Campo` · `Declarado (FQF)` · `Verificado (canal)` · `Divergência` · badge `--state-divergent` quando há gap. Ex.: `Headcount · 12 (declarado) · 5 (LinkedIn) · -58% · DIVERGENTE`.

**Estados:**
- Dados insuficientes — menos de 4 canais coletados: substitui o painel de score por banner neutro `"Aguardando mineração: 2/4 canais mínimos coletados"` com barra de progresso, sem número de score algum visível (nunca mostrar score calculado sobre base insuficiente).
- Eliminado — ver banner de knockout acima.
- "Não sei" em campo do FQF (edge case F-C.4) — tratado como resposta válida na `EvidenceRow`, badge `--state-declared` neutro com texto "não sei (resposta honesta)", nunca como campo vazio penalizável.
- Armadilha reprovada (edge case F-C.5, ex. 9.4/9.5 do FQF) — aparece como uma linha de Classe D mesmo estando fisicamente no Bloco 9 do formulário, reforçando visualmente "isto elimina, não desconta".

---

### Tela 4 · Mineração assistida

**Layout:** checklist vertical de canais, 1 linha por canal, com barra de progresso "X/4 canais mínimos" fixa no topo (o gate mais importante da tela, sempre visível).

**Canais e tratamento (MSFE §4, tabela de canais):**

| Canal | Tratamento na UI |
|---|---|
| LinkedIn — empresa/pessoas | Marcado explicitamente `"Requer sessão logada — coleta manual"` (nunca finge automação que não existe, Discovery V1 §5). Botão "abrir LinkedIn" (link externo) + campo de colagem estruturado (headcount, entradas/saídas 24m, tempo de casa) |
| Glassdoor / Love Mondays | Botão "abrir canal" + campo de colagem (depoimentos relevantes, citação direta) |
| Reclame Aqui | Idem + campo de "tom da resposta da empresa" (dropdown: cordial / neutro / defensivo) |
| Google Reviews | Idem + nota-resumo |
| Instagram | Idem + classificação (técnico datado / genérico-promocional) |
| Reddit | Idem, nota de rota técnica (`old.reddit.com`, já documentado como restrição confirmada em `~/.claude/rules/reddit-acesso-fallback.md` — reaproveitar esse fallback, não reinventar) |
| Registros públicos | Idem + status (regular/irregular) |
| Site próprio | Marcado `"Declarativo — peso mínimo"`, sempre com ícone de `--state-declared`, nunca tratado como fonte forte mesmo que fácil de coletar |

Cada linha (`ChannelStatusRow`) tem estado próprio: `pendente` (cinza, ação disponível) / `coletado` (verde, resumo visível, editável) / `bloqueado` (âmbar, com motivo — ex. "perfil privado" — e botão retry, edge case F-B.1/F-B.4, falha de canal não derruba os outros) / `não aplicável` (cinza tracejado).

**Banners contextuais:**
- Duplicata de CNPJ (edge case F-B.2): `"Este CNPJ já foi minerado na vaga [X] — reaproveitar evidência coletada?"` com ação direta.
- Sócio compartilhado (edge case F-B.3): chip informativo `"Mesmo sócio-fundador de [Candidato Y]"`, não bloqueia, só alerta.
- Candidato indicado manualmente (edge case F-B, indicação pessoal): mesmo checklist, sem pular o gate de 4 canais.

---

### Tela 5 · Comparativo e decisão

**Layout:** candidatos como colunas, critérios como linhas — nunca comparação por honorário isolado (MSFE §1.6, "comparação sempre por CTP"). Linha de cabeçalho fixa (sticky) com CTP estimado em destaque (`--text-mono-lg`), seguida por score composto, status de knockout, e barra de decomposição mini por classe.

Se os candidatos comparados **não são da mesma camada**, banner de aviso `--state-divergent` no topo da tabela: `"Candidatos de camadas diferentes não são comparáveis por CTP — MSFE §1.6"` (não bloqueia visualização, mas deixa o erro de categoria explícito antes de qualquer decisão).

**Linha de decisão** por candidato: botões `Avançar` / `Reserva` / `Eliminar`. Em F4 (análise de contrato), se `advogado-contratos` retornou NO-GO e o gestor decide prosseguir mesmo assim (edge case F-E.2), abre modal obrigatório de **exceção carimbada**: quem decidiu, timestamp, motivo (texto obrigatório) — resultado gera um `ExceptionStampBadge` visível em todo lugar onde esse candidato aparecer daqui pra frente (Tela 2, Tela 3), nunca escondido como se o gate tivesse passado normalmente.

**Estado de pool vazio** (edge case F-E.3, nenhum candidato ≥70): não é tela de erro — é uma leitura correta do método. Ilustração + texto: `"Nenhum candidato atingiu o score mínimo. O mercado pode não ter esse perfil nesta configuração de escopo — considere dividir em mais fornecedores (MSFE §10)."` Sem tom de falha do sistema.

---

## 5 · COMPONENTES

| Componente | Variantes | Estados |
|---|---|---|
| `EvidenceStateBadge` | verificado · declarado · divergente · não-coletado | default, dentro-de-linha, dentro-de-card (compacto) |
| `KnockoutChip` | reprovado · aprovado · pendente | — |
| `ScoreBar` (decomposição A/B/C) | completo · parcial (hachura em B) | hover mostra tooltip com valor exato de cada classe |
| `CandidateCard` (kanban) | padrão · indicação-pessoal · stale | hover, selecionado, arrastando |
| `CrossReferenceRow` | com divergência · sem divergência | — |
| `ChannelStatusRow` | pendente · coletado · bloqueado · não-aplicável | expandido (campo de colagem visível) / colapsado |
| `ServiceLayerSelector` (segmented control) | 4 opções fixas (camada 1–4) | uma selecionável por vez |
| `SupplierTypeCard` (radio-card) | 7 tipos fixos (MSFE §2.1) | selecionado, hover, desabilitado (tipo sem Classe D mapeada) |
| `CTPField` | — | com tooltip das 6 parcelas |
| `ExceptionStampBadge` | — | sempre visível quando presente, não há estado "oculto" |
| `StaleEvidenceFlag` | — | aparece só quando prazo de revalidação (definido em SPEC técnica) expira |
| `WarningBanner` | informativo (`--state-divergent`) · erro de sistema (`--state-eliminated`-adjacent, rotulado texto) | dismissível apenas quando informativo, nunca quando é erro de sync |
| `EmptyState` / `SkeletonCard` | — | genéricos, reusados nas 5 telas |

Nenhum componente novo além destes — cada um cobre um padrão de uso repetido em pelo menos 2 telas (`EvidenceStateBadge` aparece nas 5; `WarningBanner`/`EmptyState`/`SkeletonCard` são a base compartilhada). Não há componente dedicado por tela sem reuso.

---

## 6 · JUSTIFICATIVA DAS DECISÕES

**Por que a paleta base é a mesma da LP, mas a semântica de estado é inteiramente nova.** `--brand:#D70030` e a escala de neutros (`--black`/`--gray`/`--light-gray`) são os únicos elementos de marca que fazem sentido atravessar de "site de conversão" pra "ferramenta interna" — são o que torna o produto reconhecível como Empresa Inteligente sem esforço. Tudo o mais que a LP usa (pill, glow, ticker, hero) é ferramenta de venda, não de gestão, e a Discovery já cravou essa distinção explicitamente (natureza do artefato, "escaneada e operada, não lida"). A semântica de 4 estados de evidência não existia em lugar nenhum do repo porque nenhuma tela do repo até hoje precisou expressar "isto é verificado vs isto é só o que a pessoa disse" — é o conceito central da MSFE, e como tal, merece cor própria, nunca emprestada do `--brand` (que é ação, não fato).

**Por que abandonei Zen Dots/Space Grotesk/Satoshi.** Não é preferência estética — é a restrição de CSP declarada no briefing desta tarefa, que essa ferramenta (fora da árvore protegida do site público) precisa respeitar desde o dia 1. Trocar por font-stack de sistema é a opção que não introduz uma dependência de rede que o próprio ambiente já avisou que vai bloquear; o peso/tracking tipográfico (800 em títulos, tracking negativo) é o que realmente carrega a personalidade visual herdada da LP, não o glifo específico da Space Grotesk.

**Por que reduzi radius e abandonei pill-em-tudo.** Numa LP, todo botão quer parecer convite (pill = "clique aqui, é fácil"). Numa ferramenta de decisão de contratação, a maioria das interações não é "clique aqui casualmente" — é "decida isto com cuidado". Reservar a cápsula (`--radius-pill`) só para badges de status preserva ela como sinal de "isto é um estado", e dá ao botão de ação um visual mais contido (`--radius-md`, 8px) que combina com densidade de dado.

**O que deliberadamente evitei:**
- Gradiente/glow decorativo (presente em quase toda seção da LP) — não tem função numa tela de decisão, e compete visualmente com o que realmente precisa de destaque (divergência, knockout).
- Cor por classe de score (A vermelho, B azul, C verde, etc.) — cortado porque colidiria com a paleta semântica de evidência, que é o que precisa ser inconfundível. Classes usam escala de tinta neutra de propósito.
- Dashboard com aparência de precisão estatística — a própria MSFE (§9.5) veda "fingir rigor estatístico" com N pequeno; nenhuma tela desta spec usa gráfico de tendência/percentual de acurácia. Isso é decisão de design em nome da metodologia, não uma omissão por preguiça.

---

**Path:** `~/empresa-inteligente/docs/design/2026-08-06-recrutamento-fornecedor-spec-visual-v1.md`
**Aplicável:** implementação do protótipo HTML do módulo "Recrutamento de Fornecedor" pelo `engenheiro-frontend`
**Fonte:** Discovery v1 (`docs/discovery/2026-08-06-recrutamento-fornecedor-discovery-v1.md`) + MSFE v1.0 + FQF v1.1 + inventário real do repo `empresa-inteligente` (citado arquivo:linha, §1)
