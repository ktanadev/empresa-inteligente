# UI-REVIEW — Empresa Inteligente OS (Proposta Dark)

**Auditado:** 2026-04-27  
**Arquivo:** `/empresa-inteligente/propostadark/index.html`  
**Contexto:** Apresentação de 15 slides — pitch B2B, público C-level, ticket R$100k  
**Baseline:** Design system KTANA Dark (#000, #D70030, Zen Dots + Space Grotesk + Inter)  
**Screenshots:** Não capturados (server não detectado — auditoria por código)

---

## Pillar Scores

| Pilar | Score | Finding Principal |
|-------|-------|-------------------|
| 1. Hierarquia Visual e Tipografia | 8/10 | Tri-fonte correta, tamanhos clamp bem calibrados, glow nos números presente |
| 2. Consistência de Marca | 7/10 | #D70030 bem contido, mas slide 14 inverte fundo para vermelho — queima a regra 60/30/10 |
| 3. Layout e Espaçamento | 8/10 | 100vw×100vh, padding 5vh/6vw generoso — slide 12 tem gap: 56px entre colunas isolado |
| 4. Qualidade de Componentes | 7/10 | Cards, glow, noise, gradientes presentes — cover depende de imagem ausente |
| 5. UX de Navegação | 7/10 | Teclado + touch + dots implementados — animLock 380ms, sem ArrowUp/Down, sem Escape |
| 6. Impacto de Negócio | 8/10 | Copy C-level forte, ROI explícito, urgência — citação Anthropic atribuída incorretamente |

**Total: 45/60**

---

## Top 3 Priority Fixes

### 1. BLOCK — Imagem de capa ausente quebra slide 1 completamente

**Impacto:** O slide mais visto da apresentação renderiza com fundo preto vazio. Nenhum C-level continua vendo uma proposta que abre quebrada.

**Linha:** 222–224
```css
.cover-bg {
  background-image: url('../img/leadership-team.jpg'); /* arquivo inexistente */
}
```

**Fix:** Usar um gradiente de fallback enquanto a imagem não existir, ou converter para imagem base64/inline, ou criar o arquivo `empresa-inteligente/img/leadership-team.jpg`.

Adicionar na linha 225:
```css
background-color: var(--bg3); /* fallback se imagem não carregar */
```

---

### 2. FLAG — Slide 14 (Urgência) usa fundo vermelho sólido — viola 60/30/10

**Impacto:** A regra 60/30/10 do design system KTANA é: preto = 60%, cinza dark = 30%, vermelho = 10%. Um slide inteiro em `background: var(--red)` (linha 481) consome toda a reserva de acento de uma vez. Isso dilui o impacto do vermelho nos demais slides e parece agressivo demais para público executivo.

**Linha:** 481
```css
.s-urgency { background: var(--red); ... }
```

**Fix:** Mudar para fundo preto com glow vermelho radial intenso:
```css
.s-urgency { background: var(--bg); }
.s-urgency::before {
  background: radial-gradient(ellipse 100% 80% at 50% 0%, rgba(215,0,48,0.35) 0%, transparent 65%);
}
```
Títulos e botão mantêm branco/vermelho. Impacto emocional preservado sem rasgar a identidade.

---

### 3. FLAG — Citação Dario Amodei (Slide 6) tem atribuição incorreta

**Impacto:** Apresentação para R$100k. O prospect pesquisa a frase. Frase não é documentada publicamente nesse formato exato. Risco de perda de credibilidade no momento mais crítico do pitch.

**Linha:** 759
```html
<p class="quote-attr">Dario Amodei — CEO da Anthropic, criador do Claude</p>
```

**Fix opções (ordem de prioridade):**
1. Substituir por citação verificável com fonte e data (ex: entrevista com link)
2. Converter para dado estatístico de relatório McKinsey/Gartner com footnote
3. Usar citação paráfrase: `"Adaptado de Dario Amodei, Anthropic — 2024"`

---

## Detailed Findings

### Pilar 1: Hierarquia Visual e Tipografia (8/10)

**Pontos fortes:**
- Tri-fonte implementada corretamente: Zen Dots (títulos h1/h2/h3, números), Space Grotesk (body), Inter (labels/meta) — linhas 92–99
- `clamp()` em todos os tamanhos: h1 `clamp(2.8rem, 5vw, 4.5rem)`, h2 `clamp(1.8rem, 3vw, 2.8rem)` — sem quebra em telas menores
- Glow nos números: `text-shadow: 0 0 20px rgba(215,0,48,0.6), 0 0 40px rgba(215,0,48,0.3)` — linha 107
- Label system coerente com `letter-spacing: .14em` e `text-transform: uppercase` — linha 83
- Hierarquia clara: `--text` (#F5F5F0) → `--text2` (#BEBEB4) → `--text3` (#7A7A70) — três tons de cinza bem escalonados

**Issues menores:**
- `.card-title` usa Zen Dots em 0.95rem (linha 136) — tamanho pequeno para fonte display, pode criar pixelação em monitores não-retina
- `.step-num` renderiza "01"–"06" em Zen Dots 0.72rem (linha 196) — numerais muito pequenos perdem a geometria da fonte

---

### Pilar 2: Consistência de Marca (7/10)

**Pontos fortes:**
- `--red: #D70030` definido como variável única, nenhum valor hexadecimal hardcoded fora do `:root` — linha 13
- Vermelho usado cirurgicamente: dots ativos, labels, números, separadores de seção
- Gradiente do botão principal (`linear-gradient(135deg, #D70030 0%, #ff4d6d 100%)` — linha 149) adiciona profundidade sem desvirtuar a cor

**Issues:**
- **Slide 14 fundo vermelho sólido** (linha 481) — ver BLOCK #2 acima
- `thead` da tabela tem `background: var(--red)` (linha 203) — thead vermelho inteiro é acento pesado demais; preferível borda vermelha inferior + texto vermelho
- `two-side.right` é painel vermelho (linha 295) — metade do slide 3 em vermelho sólido, similar ao problema do slide 14. Em paralelo com o slide 14, o vermelho aparece como bloco inteiro em 2 de 15 slides = 13% do conteúdo, acima do 10% da regra

---

### Pilar 3: Layout e Espaçamento (8/10)

**Pontos fortes:**
- Todas as slides: `width: 100vw; height: 100vh` — linha 44
- Padding base: `padding: 5vh 6vw` — linha 47 — generoso e viewport-relative
- Grids consistentes: 3 colunas para cards de métricas/nichos/resultados/time, 2 colunas para produto/investimento/incluído
- `max-width` aplicado consistentemente nos containers de conteúdo (900px–980px)

**Issues:**
- `invest-split` tem `gap: 56px` (linha 432) — único uso de gap grande isolado, todos os outros grids usam 12–24px
- Slide 13 (`s-included`) usa `background: var(--bg2)` enquanto Slide 10 (`s-platform`) também usa `var(--bg2)` — dois slides seguidos com mesmo background pode criar sensação de que são a mesma seção
- Slide 5 (tabela): `table-wrap` tem `max-width: 920px` mas tabela com 3 colunas em texto longo pode truncar em 768px mesmo com `border-radius: 14px; overflow: hidden`

---

### Pilar 4: Qualidade de Componentes (7/10)

**Pontos fortes:**
- Noise texture via SVG inline: `feTurbulence + fractalNoise` com `opacity: .025` — linha 35 — implementação correta e leve
- Radial glow em slides múltiplos: slide 2, 6, 12, 14, 15 têm `::before` com gradiente radial — linha 270, 344, 428, 484, 506
- Cards com hover completo: `border-color + box-shadow + transform: translateY(-2px)` — linhas 130–135
- Botão pulse animado com `@keyframes pulse-glow` — linha 523 — detalhe premium no CTA final
- Dots de navegação: dot ativo vira pill `width: 18px; border-radius: 3px` — linha 75 — padrão moderno

**Issues:**
- **Cover image ausente** — ver BLOCK #1 acima. A ausência transforma o slide mais importante em fundo preto vazio
- `.cover-glow` radial está centrado em `30% 60%` (linha 233) — glow vai para esquerda/baixo enquanto o texto está à esquerda/baixo. O glow compete com o conteúdo em vez de iluminar o hero
- Slide 9 (Time): cards sem hover animation (`.team-card` — linha 381) — única família de cards sem `transition`, inconsistente com os demais
- `quote-mark` usa `font-family: 'Georgia', serif` (linha 348) — única ocorrência de serif em todo o documento, quebra pureza do design system. Substituir por SVG ou caractere em Space Grotesk italic

---

### Pilar 5: UX de Navegação (7/10)

**Pontos fortes:**
- Keyboard: `ArrowRight`, `Space` (com `preventDefault`), `ArrowLeft` — linhas 1021–1023
- Touch: swipe com threshold 50px, passive listeners — linhas 1027–1033
- Dots: click direto para qualquer slide, estado ativo sincronizado — linhas 997–1001
- Animation lock: `animating = true` com timeout 380ms evita race condition — linha 1017
- Counter `1 / 15` no topo direito — linha 551

**Issues:**
- **Sem ArrowUp/ArrowDown** — apresentações costumam aceitar também as setas verticais para avançar
- **Sem suporte a tecla `Escape`** para voltar ao slide 1 (útil em demo ao vivo)
- **Sem `Home`/`End`** para ir ao primeiro/último slide
- **Dots com 15 itens** ficam muito juntos em mobile (6px de tamanho, 8px de gap). No iPhone SE (375px): 15 × 6 + 14 × 8 = 202px — passa levinho. Mas o dot ativo cresce para 18px — pode causar reflow visual em telas pequenas
- Sem `aria-label` nos dots: inacessível para screen readers. Adicionar `aria-label="Ir para slide ${i+1}"` e `role="button"` na linha 999

---

### Pilar 6: Impacto de Negócio (8/10)

**Pontos fortes:**
- Copy orientada a dor: "Sua empresa ainda opera no modo manual?" — direto para o C-level
- ROI explícito e específico: "R$150k–R$400k de economia no 1° ano" para empresa de R$5M/ano
- Prova social com fontes: FGV/IBRE 2024, McKinsey 2024, Gartner 2024 — linha 595–605
- Urgência genuína com argumento lógico ("implementação exige dedicação exclusiva") — linha 968
- CTA consistente em 3 slides (1, 14, 15) — mesmo URL `empresainteligente.ai/diagnostico`
- Diferenciação clara: "Não é um curso. Não é consultoria. É implementação." — linha 771

**Issues:**
- **Citação Dario Amodei incorretamente atribuída** — ver BLOCK #3 acima
- Slide 9 tem apenas primeiro nome ("Matheus", "Leandro") — C-level vai querer sobrenome, LinkedIn, credenciais verificáveis. Lacuna de confiança em proposta de R$100k
- "4 vagas disponíveis neste trimestre" (linha 964) sem data do trimestre — prospect não sabe se é Q1 2025 ou Q4 2026, dilui urgência
- Disclaimer de fontes só aparece no slide 11 (linha 906) mas dados de FGV/McKinsey/Gartner são usados também no slide 2 — inconsistência de attribution

---

## Issues Adicionais (Menores)

| # | Tipo | Linha | Descrição |
|---|------|-------|-----------|
| M1 | FLAG | 136 | `.card-title` em Zen Dots 0.95rem — fonte display em tamanho corpo |
| M2 | FLAG | 203 | `thead` vermelho sólido — acento pesado para tabela longa |
| M3 | FLAG | 295 | `two-side.right` background vermelho sólido — segunda violação 60/30/10 |
| M4 | FLAG | 348 | `quote-mark` em Georgia serif — fonte estranha ao design system |
| M5 | FLAG | 381 | `.team-card` sem hover transition — inconsistente com outros cards |
| M6 | FLAG | 432 | `gap: 56px` isolado em invest-split — espaçamento fora do padrão |
| M7 | FLAG | 999 | Dots sem `aria-label` — inacessível |
| M8 | FLAG | 839 | Time card sem sobrenome/credenciais verificáveis |
| M9 | INFO | 233 | Cover glow position conflita com posição do texto |
| M10 | INFO | 964 | "4 vagas neste trimestre" sem data específica |

---

## Files Audited

- `/Users/juliocesarmacbookblack/empresa-inteligente/propostadark/index.html` (1037 linhas)
- `/Users/juliocesarmacbookblack/empresa-inteligente/img/leadership-team.jpg` — **arquivo ausente** (referenciado na linha 222)
