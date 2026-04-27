# UI Review — Proposta White (Empresa Inteligente OS)

**Audited:** 2026-04-27
**File:** propostawhite/index.html
**Baseline:** Design system KTANA White (#FFF, #D70030, Zen Dots + Space Grotesk + Inter)
**Screenshots:** Not captured (no dev server detection requested — code audit)

---

## Pillar Scores

| Pillar | Score | Key Finding |
|--------|-------|-------------|
| 1. Visual Hierarchy & Typography | 8/10 | Fontes corretas aplicadas; scale poderia ser mais agressivo nos títulos |
| 2. Brand Consistency (Red #D70030) | 7/10 | Vermelho subliminar e contido — mas overuse em elementos de dados |
| 3. Layout & Spacing | 8/10 | Slides 100vw×100vh, padding 52px generoso; slide 3 rompe o padrão |
| 4. Component Quality | 9/10 | Cards, badges, checklist e tabela com qualidade premium |
| 5. Navigation UX | 8/10 | Teclado + touch + dots implementados; falta PageDown e foco visível |
| 6. Business Impact | 7/10 | Proposta clara para C-level; slide 6 contém claim impreciso crítico |

**Total: 47/60**

---

## Top 3 Priority Fixes

1. **BLOCK — Claim falso no Slide 6 (linha 747)** — "O mesmo Claude já implementado em mais de 3.000 empresas brasileiras" é uma afirmação não verificável e que pode ser considerada enganosa em contexto comercial. Impacto: destrói credibilidade com CEO que questionar a fonte. Fix: remover a frase de atribuição secundária ou substituir por "utilizado por empresas em todo o Brasil".

2. **BLOCK — Telefone placeholder no Slide 15 (linha 1004)** — `(11) 99999-9999` é um número fictício exposto na CTA final. Se o deck for compartilhado com prospects, o contato não funciona. Fix: substituir pelo número real antes de qualquer distribuição.

3. **FLAG — Slide 3 (linha 198) quebra o grid padrão** — Único slide que usa `display:flex; height:100%` fullscreen sem `.slide-inner`, enquanto todos os outros usam `max-width:1160px; padding:0 52px`. A ausência de `max-width` faz o conteúdo esticar em monitores ultrawide (>1600px), quebrando a proporção dos dois painéis. Fix: envolver `.two-wrap` em um container com `max-width:1600px; margin:0 auto` ou limitar os painéis.

---

## Detailed Findings

### Pillar 1: Visual Hierarchy & Typography (8/10)

**Positivo:**
- Zen Dots aplicado corretamente em h1, h2, e `.stat-val` / `.metric-num` / `.team-name` (linha 36, 379)
- Space Grotesk como body padrão no `html,body` (linha 26) — correto
- Inter para labels, badges e metadados — correto e consistente
- Hierarquia visual clara: label (11px/Inter/uppercase) → h2 (clamp 1.5–2.2rem/Zen Dots) → body (14-15px/Space Grotesk)
- `clamp()` bem aplicado em todos os títulos — responsivo sem quebrar

**Issues:**
- **FLAG** — Slide 9 (linha 379): `.team-name` usa `font-size:18px` / Zen Dots para nomes genéricos ("Matheus", "Leandro"). Em tela grande, Zen Dots em 18px é pesado e não serve para nomes próprios — parece estilização de logo em contexto errado. Considerar Space Grotesk bold para nomes de pessoas.
- **FLAG** — Slide 8 (linha 363): `.step h4` usa `font-size:14px` para títulos de fase. Com 6 steps em grid 3 colunas, o título "Diagnóstico Estratégico" em 14px bold mal se destaca da descrição em 13px. Diferença de apenas 1px entre h4 e p. Fix: aumentar para 15-16px.
- **FLAG** — Slide 10 (linha 400): `.plat-value` usa Zen Dots 12px para "VALOR: R$24.000/ano — INCLUSO NO OS". Zen Dots em 12px é ilegível em apresentação projetada. Fix: 14px mínimo ou trocar para Space Grotesk bold.

---

### Pillar 2: Brand Consistency — Red #D70030 (7/10)

**Positivo:**
- `--red:#D70030` definido como variável CSS (linha 13) — sem hardcode
- Red usado de forma subliminar: top border em cards, label lines, check icons — não gritante
- Slides 1-13 (white/light) mantêm red como acento, não dominant color
- Slides 14 (red bg) e slide 3 (dark panel) criam contraste proposital — decisão correta de direção de arte

**Issues:**
- **FLAG** — Red overuse em dados: Slides 2, 11, 12 usam `color:var(--red)` para TODOS os números grandes (`.stat-big`, `.metric-num`, `.price-main`). Em uma grade de 6 métricas (slide 11), seis números vermelhos simultâneos diluem o impacto do vermelho como cor de ênfase — todos chamam atenção igualmente, nenhum chama.
  - Slide 2 (linha 183): 3 × `stat-big` em red
  - Slide 11 (linha 410): 6 × `metric-num` em red
  - Fix: manter red em 1-2 KPIs de destaque; usar `var(--text)` ou `var(--text2)` para os demais com label em red
- **FLAG** — Slide 14 (linha 451): fundo inteiro `background:var(--red)`. Justificado como slide de urgência, mas com dots também mudando para branco e counter em red, o único slide de impacto máximo dilui ao aparecer junto com o restante da paleta. Aceitável editorialmente, mas avaliar se cria dissonância com o posicionamento premium.
- **OK** — Não há hardcode de hex fora das variáveis. Toda referência ao vermelho passa pela var ou `rgba(215,0,48,...)`.

---

### Pillar 3: Layout & Spacing (8/10)

**Positivo:**
- `100vw × 100vh` com `overflow:hidden` — fullscreen correto (linha 27-34)
- `.slide-inner` com `max-width:1160px; padding:0 52px` — largura de conteúdo premium, bem centralizado (linha 48)
- Padding interno dos cards consistente: 30px (slides 7, 11), 26px (slide 4), 28px (slide 11)
- Gap entre grid items consistente na faixa 16-24px em todos os slides

**Issues:**
- **BLOCK** — Slide 3 (linha 198-199): `.two-wrap` e `.panel` usam `width:100%; height:100%` sem nenhum `max-width`. Em monitores de 27" ou ultrawide, os dois painéis ficam com ~800px de largura cada, criando paredes de texto mal legíveis. Fix:
  ```css
  .s-two .two-wrap { max-width: 1400px; margin: 0 auto; }
  ```
- **FLAG** — Slide 12 (linha 418): `.invest-grid` usa `gap:52px` — o maior gap do deck. Com apenas 2 colunas, este gap empurra o bloco de preço para a esquerda extrema e a lista para a direita extrema, criando desequilíbrio visual em telas 1024-1280px. Fix: reduzir para 36-40px.
- **FLAG** — Slide 13 (linha 441): `.checks-grid` usa `gap:0 52px` — zero gap vertical entre colunas, 52px horizontal. Os itens das duas colunas em 8 linhas ficam próximos verticalmente (só 13px de `margin-bottom` no `.check-item`), mas as colunas têm 52px de separação — proporção invertida. Fix: `gap: 4px 40px`.
- **FLAG** — Slide 6 (linha 737): a label usa `style` inline com `color:rgba(255,255,255,0.32)` e `<span>` para o traço decorativo, quebrando o padrão `.label::before` do restante. Inconsistente com a implementação do CSS. Fix: criar variante `.label.label-dark` no CSS em vez de estilos inline.

---

### Pillar 4: Component Quality (9/10)

**Positivo:**
- `.badge-red` (linha 91-95): padding, border-radius, border semitransparente — execução clean
- `.check-icon` e `.x-icon` (linhas 99-108): SVG com stroke correto, flex-shrink para não comprimir
- `.transform-table` (slide 5): header com grid `160px 1fr 48px 1fr`, hover state, alternância de fundo par/ímpar — tabela de qualidade premium
- `.nicho-card:hover` com `::after` scaleX animation (linhas 237-238): micro-interaction elegante
- Buttons `.btn-red` e `.btn-white` com hover transform e shadow depth — correto
- `.anth-badge` no slide 6 (linha 312): componente de credencial com glassmorphism sutil — adequado

**Issues:**
- **FLAG** — Slide 9 (linha 372-382): `.team-card` não tem `border-top:3px solid var(--red)` como os demais cards do deck. Inconsistência: slides 2, 7 e 8 usam essa borda top como elemento de identidade. Time cards ficam visualmente mais "básicos" que outros cards. Fix: adicionar `border-top:3px solid var(--red)` ao `.s-team .team-card`.
- **FLAG** — `.team-avatar` (linha 374): usa SVG genérico de user/person como placeholder. Em uma proposta de R$100k para CEOs, avatars de silhueta genérica prejudicam a percepção de credibilidade da equipe. Fix: foto real com `border-radius:50%` + `object-fit:cover` ou iniciais em Zen Dots.
- **FLAG** — `.dot` (linha 68): dots de navegação têm `width:6px; height:6px`. Em projetor ou TV 4K (distância 3m+), dots de 6px são praticamente invisíveis. Fix: aumentar para `width:8px; height:8px`.

---

### Pillar 5: Navigation UX (8/10)

**Positivo:**
- Keyboard: ArrowRight, Space (avança), ArrowLeft (volta), Home, End (linhas 1052-1057) — cobertura completa
- Touch: touchstart/touchend com threshold 50px (linhas 1059-1064) — passivo e correto
- Dots com `aria-label="Slide N"` (linha 1023) — acessibilidade básica OK
- Counter com tema adaptativo (dark/red/light) — detalhe de qualidade (linhas 1031-1040)
- `pointer-events:none` em slides inativos — previne cliques em slides ocultos

**Issues:**
- **FLAG** — Nenhum `focus-visible` definido para os `.dot` buttons (linha 68-75). Usuário navegando por teclado (Tab) não vê qual dot está focado — viola WCAG 2.4.7. Fix:
  ```css
  .dot:focus-visible { outline: 2px solid var(--red); outline-offset: 3px; }
  ```
- **FLAG** — PageDown/PageUp não mapeados (linha 1052). Presenters frequentemente usam clickers que enviam PageDown. Fix: adicionar ao keydown listener:
  ```js
  else if (e.key === 'PageDown') { e.preventDefault(); go(cur + 1); }
  else if (e.key === 'PageUp') { e.preventDefault(); go(cur - 1); }
  ```
- **FLAG** — Sem `role="region"` ou `aria-label` nas sections de slide. Screen readers anunciam apenas "section" sem contexto. Fix: `aria-label="Slide N de 15"` em cada `<section>`.
- **FLAG** — Transição é apenas `opacity` (linha 32). Em projetor com latência de display, a transição de 380ms pode parecer lenta. Considerar `transition: opacity 240ms ease-in-out`.
- **INFO** — Slide 3 tem `data-theme="half"` mas o JS não trata este valor (linha 1033-1038). O counter e dots ficam com tema "light" (sem classe), o que é visualmente correto dado que o slide é split, mas o theme value é inconsistente com o sistema.

---

### Pillar 6: Business Impact (7/10)

**Positivo:**
- Fluxo narrativo C-level correto: Problema → Urgência → Solução → Prova → Preço → Ação
- Slide 1 (capa) entrega proposta de valor em 2 linhas — claro e direto
- Slide 3 (dois tipos) é o melhor slide para CEO: reconhecimento imediato de qual empresa é a deles
- ROI explícito no slide 12: "R$5M/ano → R$150k–R$400k de economia no 1° ano" — linguagem de resultado
- "4 vagas por trimestre" cria escassez real e justifica exclusividade (slide 14)
- Fontes citadas (McKinsey, Gartner, FGV 2024) adicionam credibilidade para tomadores de decisão

**Issues:**
- **BLOCK** — Slide 6 (linha 747): `"O mesmo Claude já implementado em mais de 3.000 empresas brasileiras"` — esta afirmação é improvável de ser verdade e não tem fonte. CEO que pesquisar vai questionar. Essa frase transforma um slide de autoridade em risco de credibilidade. Fix: remover completamente ou substituir por algo verificável como "Disponível para empresas em todo o Brasil".
- **BLOCK** — Slide 15 (linha 1004): número de WhatsApp `(11) 99999-9999` é fictício. Em qualquer distribuição do deck, o lead que tentar usar o WhatsApp encontrará o número inválido. Fix: inserir número real antes de qualquer compartilhamento.
- **FLAG** — Slide 9 (Time): avatars genéricos de SVG para "Matheus" e "Leandro" sem foto, empresa, LinkedIn ou credencial verificável. Para uma proposta de R$100k, o comprador precisa confiar nas pessoas — bios sem rosto são insuficientes para essa decisão. Fix: fotos reais ou ao menos logos de empresas anteriores onde trabalharam.
- **FLAG** — Slide 11 (Resultados, linha 919): "Baseado em dados de empresas que implementaram IA — McKinsey, Gartner, FGV 2024" como rodapé de 12px em itálico. As fontes são importantes — este disclaimer deveria ter pelo menos 13px e não estar em itálico que reduz legibilidade.
- **FLAG** — Não há slide de "cases" ou depoimento de cliente real. O slide 6 usa citação de CEO da Anthropic — potente, mas externo. Um case de cliente real (mesmo anonimizado: "Escritório contábil de SP, R$8M/ano, reduziu 40% do quadro de analistas") seria mais convincente para o estágio de fechamento.
- **INFO** — A imagem de fundo no slide 1 (`../img/leadership-team.jpg`) usa path relativo. Se o arquivo não existir, o fundo fica branco — sem fallback de cor ou gradiente. A `cover-overlay` garante que o conteúdo seja legível, mas o slide perde o apelo visual da foto. Fix: `background:#F0F0EE` como fallback na `.s-cover .cover-bg`.

---

## Registry Safety

Não aplicável — sem `components.json` (shadcn não inicializado).

---

## Files Audited

- `/Users/juliocesarmacbookblack/empresa-inteligente/propostawhite/index.html` (1069 linhas — arquivo único, CSS + HTML + JS inline)
