# CONTEXT — Redesign Apresentação Empresa Inteligente OS

**Data:** 2026-05-01
**Repo:** `~/empresa-inteligente/`
**Branch atual:** `feature/proposta-grupo-silva`
**Branch de trabalho:** `fix/redesign-clean-liquid-glass` (a criar)
**Arquivo:** `oferta/index.html` (77KB, 13 slides, HTML+CSS+JS inline, 1440×810px)
**Diagnóstico Notion:** https://app.notion.com/p/35372d328c7c81a988a0e5b43dd7f5d9
**Design System Notion:** https://app.notion.com/p/33272d328c7c81729c5ed0904b5ec467
**Referência G4:** https://app.notion.com/p/34f72d328c7c81a49232ccb6bef14515

## OBJETIVO

Redesign visual do deck preservando copy validada. Eliminar 9 erros críticos, aplicar Design System KTANA Ive Edition, gerar PDF para Drive, abrir PR.

## RESTRIÇÕES INVIOLÁVEIS

- Capa S1 — copy headline+sub+meta JÁ feita pelo Julio. **NÃO ALTERAR**.
- Slides S2-S12 — copy já passou por COPY WRITER (commits b1b8242, 3632d10). **PRESERVAR**.
- KTANA cyberpunk SOMENTE em S1+S12. **PROIBIDO** em S2-S11.
- PROIBIDO ABSOLUTO: kanji 刀, ktana-samurai-*.png, estilo asiático.
- Manter navegação keyboard + touch + scaling + @media print funcionais.

## CONSENSO DOS 6 ESPECIALISTAS

### Arquiteto (Plan)
- Refactor **incremental** no mesmo arquivo (commits atômicos por slide)
- Manter `:root`, `.deck` 1440×810, scaling JS, @media print intactos
- Adicionar tokens novos em `:root` sem remover existentes
- Código morto removível: `.kg-glow-behind`, `.kg-pulse`, `--bg3`, `.sw-alt`, `.h1`/`.kpi-num` genéricos

### PM
- Onda única (não faseado)
- Erro destruidor: #5 design system (base de tudo) — ler Notion antes de tocar pixel
- Riscos: regressão de copy, descaracterização de marca, scope creep

### PO (empresário-target)
- Empresário desiste em S4 (stats genéricos) e S7 (vira "curso")
- Convence em S10 (200+ empresas, 73h economizadas)
- **Mover S10 para ANTES de S6** (prova antes de explicar)
- Manter S5b, **CORTAR S10b** (esfria pré-preço)
- Reposicionar "KTANA-me" como "Assistente IA pessoal incluso"

### Analista Negócio
- 4/5 stats S4 sólidas; 1 frágil (FGV-EAESP+Sebrae 30%)
- "MORRER vs DOMINAR" agressivo demais — sugere "Liderar ou ser liderado"
- Falta calculadora ROI explícita (R$100k ÷ economia mensal)
- **Adicionar slide de case real nominal entre S10 e S11**
- S8 sem sobrenome/LinkedIn = risco para R$100k

### Designer UI/UX
- #D70030 max **8% por slide**, NUNCA em background/text-corrido
- 4 cards-tipo: kpi (1px border, 2px accent top 4px wide), feature (liquid glass blur 20px), quote (border-left 3px), step (32px circle)
- Hierarquia: Zen Dots H1 64px / Satoshi H2 32px+H3 22px / Inter body 16px+label 13px+caption 12px
- Ambient glow só em **S1, S8, S13** (3 slides)
- Density target: **max 5 elementos visuais distintos por slide**
- Whitespace mínimo: 96px top/bottom, 80px lateral

### Eng Software
- backdrop-filter SELETIVO: só em containers de 1º nível (~13 elementos, NÃO 50)
- v19_*.jpg de 5-7MB → **PDF crash**. Reotimizar para ≤400KB ou NÃO usar
- @media print: forçar override sem backdrop-filter (`bg: rgba(255,255,255,0.95)` opaco)
- Satoshi via Fontshare CDN (não Google Fonts) com fallback Inter
- Ambient glow `position:absolute` + `z-index:0` + `pointer-events:none` + `will-change` só durante anim
- **Baseline puppeteer ANTES de tocar** (screenshot v1 dos 13 slides)

### Designer Branding
- KTANA = endosso institucional. EI OS = produto protagonista. **Não inverter.**
- S1: produto domina, "powered by KTANA" sutil 9pt
- S2-S11: produto 100%, KTANA só footer
- S12: KTANA volta como assinatura
- S1 sem kanji: **linha diagonal vermelha #FF1A4B 1-2px glow 12px** corta o slide (substitui kanji)
- Avatar S1: half-split direita 45% full-bleed, gradient red→black borda esquerda, grain 8%
- 4 elementos persistentes: breadcrumb topo-esq, counter topo-dir, footer logo rodapé-esq, endosso rodapé-dir
- **Ritmo de paleta:** dark/light/light/dark-pivot(S5)/light/light/dark-pivot(S8)/light/light/dark
- Arquétipo: Mestre Guerreiro + Governante (autoridade serena, não venda agressiva)
- 3 erros novos: "POWERED BY KTANA AI" caixa-alta = ruído (reduzir para "powered by KTANA"), vermelho usado como cor de texto (errado), falta espaço vazio assinatura (Ive exige 25-30% morto)

## DECISÕES JÁ TOMADAS PELO ORQUESTRADOR

1. **Refactor incremental** no `oferta/index.html` (Arquiteto vs Eng Software — escolhi Arquiteto). Para mitigar risco do Eng: gerar baseline puppeteer ANTES + commits atômicos para rollback cirúrgico.
2. **Density 5 max + 8% red max + 3 ambient glow slides** — consenso UI/UX + Branding.
3. **CSS herda `.kg-white` nas classes existentes** (não trocar HTML) — Eng.
4. **Reotimizar v19_*.jpg para ≤400KB** antes de adicionar (sem isso, PDF crasha).
5. **Satoshi via Fontshare CDN** com fallback Inter.
6. **Substituir kanji por linha diagonal vermelha #FF1A4B** (Branding).
7. **Footer "powered by KTANA"** (minúsculo, sem "AI" redundante).

## DECISÕES QUE PRECISAM DO JULIO (mexem em conteúdo/produto)

| # | Pergunta | Sugestão dos especialistas |
|---|----------|---------------------------|
| A | Mover S10 (Resultados) para ANTES de S6 (O que é)? | SIM — empresário compra prova antes de processo |
| B | Cortar bumper S10b? | SIM — atrasa pré-preço |
| C | Adicionar slide de **case real nominal** com antes/depois entre S10 e S11? | SIM — precisa nome empresa + métrica |
| D | Renomear "KTANA-me" para "Assistente IA pessoal incluso"? | SIM — empresário 45+ estranha "KTANA-me" |
| E | Trocar S2 "MORRER vs DOMINAR" por "Liderar ou ser liderado"? | SIM — agressivo demais para B2B premium |
| F | S8 — pedir sobrenome+LinkedIn de Matheus/Leandro ou cortar nomes próprios? | SIM — sem credencial = risco em R$100k |
| G | Trocar fonte FGV-EAESP+Sebrae 30% por dado IBGE/Sebrae rastreável? | SIM — frágil sob fact-check |

## ASSETS DISPONÍVEIS NO REPO

- `img/ktana-cyberpunk-hr.jpg` (430KB) — capa+contracapa
- `assets/ktana-cyberpunk-video.mp4` (297KB) — alternativa animada
- `img/dario-amodei.jpg` (802KB) — S5 (já em uso)
- `img/cover-hero.jpg`, `problem.jpg`, `solution.jpg`, `authority.jpg`, `ai-future.jpg`, `ai-business.jpg` — heroes
- 12× `v19_*.jpg` (5-7MB cada) — **REOTIMIZAR antes de usar**
- `img/leadership-team.jpg` (112KB) — alternativa para S5/S8
- `img/leader-clone.jpg` (162KB, foto editorial brasileira aprovada)

## PROIBIDOS

- `img/ktana-samurai-attack.png`
- `img/ktana-samurai-kasa.png`
- `img/ktana-samurai-neon.png`
- Qualquer kanji 刀 ou caractere asiático
- Avatar/personagem KTANA em S2-S11

## DELIVERABLES

1. `oferta/index.html` redesenhado (push para feature/proposta-grupo-silva via PR)
2. `oferta/oferta-empresa-inteligente.pdf` no Drive (pasta da Empresa Inteligente)
3. Commits atômicos por correção
4. Tag `v2-redesign-clean-stable`
5. Screenshot puppeteer dos 13 slides (baseline + final)
