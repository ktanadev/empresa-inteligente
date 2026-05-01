# Handoff — Empresa Inteligente Design Fixes

**Criado:** 2026-04-19 14:08  
**Branch:** main  
**Último commit:** `3978063` — fix: logo v6, textura CSS crimesim, link blog, remove imagens sobrepostas  
**Repo:** https://github.com/ktanadev/empresa-inteligente  
**Site live:** https://empresainteligente.ai/

---

## Estado Atual

Sessão de design focada em `index.html`. Todas as mudanças foram **commitadas e publicadas** no GitHub Pages (commit `3978063`). O site ao vivo deve refletir tudo em ~2 min após o push.

---

## O Que Foi Feito Nesta Sessão

### 1. Logo — Sistema Tipográfico v6 (nav + footer)

**Problema:** Logo usava SVG geométrico para EMPRESA (letras retangulares custom) — errado.  
**Solução aplicada:**

- **EMPRESA** → Zen Dots 400, uppercase, `#0B0B0C` (nav) / `rgba(255,255,255,0.92)` (footer)
- **inteligente** → IBM Plex Sans Light Italic 300, `#BC002D`, com técnica i-dot:
  - Letra `ı` (dotless i Unicode) + `<span class="tittle">` absolutamente posicionado (círculo vermelho)
  - Classes: `.nav-i-dot .stem` e `.nav-i-dot .tittle`
- **AI** → Zen Dots 400, `#BC002D`, letter-spacing `.06em`

Font loading adicionado: `1,300` ao IBM Plex Sans (era só 1,400;1,600;1,700).

### 2. Textura CSS Crimesim — `.how` e `.final-cta`

**Problema:** Seções usavam `url('assets/institucional-textura.jpg')` — foto real com texto impresso sobrepondo o conteúdo da LP ("A confiança é a moeda mais cara." e arcos brancos).  
**Solução aplicada:** Textura 100% CSS:

```css
background-image:
  url("data:image/svg+xml,...feTurbulence fractalNoise baseFrequency='0.022 0.015' numOctaves='7' seed='3'..."),
  radial-gradient(ellipse ... rgba(225,10,48,0.58) ...),  /* 5-6 gradientes radiais */
  linear-gradient(148deg, #520010 0%, #9A0024 30%, #C0002C 54%, #850020 76%, #3E000E 100%);
```

Referência visual: tecido amassado carmesim da pasta KTANA-EFE/INSTITUICIONAL. NÃO usar a foto — é só referência de estilo (cor, temperatura, profundidade orgânica).

### 3. Imagens Sobrepostas Removidas

- **`footer::after`** — crystal cube ghost (8% opacity) removido. Texto da foto vazava.
- **`.final-cta-ghost`** — crystal cube ghost (5% opacity) removido. `display: none`.
- **`footer::before`** — mantido (radial-gradient vermelho sutil, sem foto).

### 4. Link Blog Corrigido

- **Era:** `https://blog.empresainteligente.ai`
- **Agora:** `https://empresainteligente.ai/blog`

**Regra confirmada pelo Julio:** A única URL do blog é `empresainteligente.ai/blog`. NÃO usar subdomínio `blog.empresainteligente.ai`.

---

## Contexto Crítico Para Próxima Sessão

### Assets disponíveis (não usar como background direto)
```
assets/institucional-cubo.jpg    — cristal sobre carmesim. Referência visual institucional KTANA.
assets/institucional-textura.jpg — tecido amassado carmesim. Referência de estilo APENAS.
```
Julio explicitou: "nao e para usar ela seu burro e referencia de estilo estetico" — a foto da textura tem textos impressos que vazam mesmo com alta opacidade de overlay.

### Tokens CSS usados
```css
--ink: #0B0B0C          /* sumi, fundo dark */
--paper: #FEFEF6        /* off-white */
--accent-grad: linear-gradient(135deg, #E5433A 0%, #A01E24 48%, #4A0E12 100%)
--shadow-blade: 0 20px 60px -20px rgba(107,15,20,.45)
--hinomaru: #BC002D     /* vermelho v6 */
```

### `.final-cta::before` — bug resolvido
O CSS antigo tinha `.final-cta::before { content: none; }` no bloco de ambient glow (linha ~1465) que sobrescrevia o overlay da textura. Removida a linha `content: none` de `.final-cta::before`. O `::after` ainda tem `content: none`.

### Fontes carregadas (Google Fonts)
```
Zen Dots | Space Grotesk 400-800 | Inter 400-600 
IBM Plex Sans: 0,400; 0,600; 1,300; 1,400; 1,600; 1,700
JetBrains Mono 400-500
Satoshi 400,500,700 (via api.fontshare.com)
```

---

## Arquivos Críticos

| Arquivo | Localização | Nota |
|---------|-------------|------|
| LP principal | `index.html` (3000+ linhas, único arquivo) | GitHub Pages — tudo inline |
| Cubo institucional | `assets/institucional-cubo.jpg` | Referência visual, não usar como bg |
| Textura | `assets/institucional-textura.jpg` | Referência de ESTILO APENAS |
| Admin DNS | `admin.html` | Painel diagnóstico DNS/rotas |

---

## Próximos Passos Possíveis

1. **QA visual completo** — navegar o site ao vivo após propagação (aguardar ~2 min do push) e verificar logo v6, texturas, ausência de imagens sobrepostas
2. **Mobile** — verificar se logo v6 quebra em telas pequenas (Zen Dots pode precisar de font-size ajustado no breakpoint ≤768px)
3. **Diagnostico.html** — página `/diagnostico.html` referenciada no admin.html — verificar se existe no repo

---

## Regras Do Projeto

- **Stack:** HTML/CSS/JS puro. Single-file `index.html`. GitHub Pages. Zero build step.
- **Design:** Fundo claro (`--paper #FEFEF6`), vermelho `#BC002D` / `#D70030`, tipografia Zen Dots + Satoshi
- **Logo:** Sistema v6 tipográfico (Zen Dots + IBM Plex Light Italic). NUNCA SVG geométrico EMPRESA.
- **Texturas escuras:** CSS puro (gradientes + feTurbulence). NUNCA fotos com texto embutido.
- **Blog:** Sempre `empresainteligente.ai/blog`. Nunca `blog.empresainteligente.ai`.
- **Imagens institucionais:** São referências visuais — NÃO usar como `background-image` direto.
