# Handoff — Design System morteempresas + Imagens PME

**Data:** 2026-04-19  
**Branch:** main  
**Commit atual:** 97c673b  
**Projeto:** /Users/juliocesarmacbookblack/empresa-inteligente  

---

## Estado Atual

A página `morteempresas/index.html` passou por dois blocos de trabalho nesta sessão:

### 1. Imagens (concluído parcialmente)
- `hero-stress.jpg` — aprovado pelo Julio (homem careca de óculos, noite, trabalhando sozinho)
- `ai-business.jpg` — gerado via Freepik API: homem moreno brasileiro com braços cruzados em farmácia/loja
- `leadership-team.jpg` — gerado via Freepik API: 4 brasileiros diversos em mesa, escritório modesto, paredes teal
- `leader-clone.jpg` — **AINDA RUIM**: executivo branco cabelo prateado com tablet em reunião corporativa americana. Precisa substituir por líder(es) brasileiros, felizes, PME.

### 2. Design System (concluído nesta sessão)
Aplicado o sistema do ktana-prototype (`ktanadev.github.io/ktana-prototype/pj/landing.html`):
- Zen Dots `font-weight: 400` em todos os headings (era 800/700)
- Tamanhos h1 max `3.5rem`, h2 max `2.4rem`
- `--text: #1D1D1F`, `--muted: #86868B`
- Satoshi (`var(--font-s)`) para subtítulos e parágrafos
- Fundos pesados `#0A0A0A` → `#111` (results-dark, final-cta, lideranca-banner)
- Footer migrado para `var(--bg-2)` (claro)

---

## Contexto Crítico

### Identidade Visual PME Brasileiro
- **PROIBIDO nas imagens:** gráfico subindo, empresário com celular sorrindo, executivo americano, escritório multinacional, logo de IA holográfico
- Estilo correto: editorial real, rostos brasileiros (moreno/pardo), ambientes PME reais, luz quente, pessoas engajadas
- NÃO usar KTANA photographic DNA (Wong Kar-Wai, dark cinematic) nesta página — é PME, não tech

### Freepik API (MCP offline)
- Endpoint direto: `POST https://api.freepik.com/v1/ai/text-to-image`
- API Key: `FPSX68a0cb43f60519861ad0a70f9d000057` (buscar no cérebro se não lembrar)
- Engine: `magnific_sharpy`, guidance_scale: 7
- Retorna base64 JPEG 1024x1024

### Design System Referência
- URL: `https://ktanadev.github.io/ktana-prototype/pj/landing.html`
- Tokens: Zen Dots `400`, Satoshi para corpo, `#F5F5F7` bg, `#1D1D1F` text, `#86868B` muted
- Sem negros pesados `#0A0A0A`

---

## Próximos Passos Imediatos

1. **Substituir `leader-clone.jpg`** — gerar via Freepik API: líderes brasileiros, equipe de 2-3 pessoas, felizes, escritório PME, luz natural, tom positivo (NÃO executivo americano)
2. **Verificar no browser** — navegar `empresainteligente.ai/morteempresas` e tirar screenshot para validar tipografia
3. **Ajustar se necessário** — o Julio pode querer mais ajustes no design system após ver ao vivo

---

## Arquivos Críticos

- `morteempresas/index.html` — página principal (único arquivo de conteúdo)
- `img/leader-clone.jpg` — imagem ruim, precisa substituir
- `img/hero-stress.jpg` — aprovado
- `img/ai-business.jpg` — aprovado
- `img/leadership-team.jpg` — aprovado

---

## Decisões Tomadas

| Decisão | Motivo |
|---------|--------|
| Git reset para e78c303 (18/04) | Julio pediu voltar ao estado anterior pois mudanças em cores de texto foram indesejadas |
| Fundos #111 em vez de #F5F5F7 nas seções dark | Seções resultados/CTA mantêm contraste alto mas menos agressivo que #0A0A0A |
| Footer claro | Alinhamento com ktana-prototype que tem footer em bg-2 claro |
| Satoshi como var(--font-s) | Mantém compatibilidade com Inter como fallback |

---

## Gotchas

- Freepik MCP está offline — usar API REST direta
- `font-weight: 700` ainda pode aparecer em alguns `.clone-card h4`, `.section-img-caption strong` — verificar
- GitHub Pages demora 1-2 min para propagar após push
- NÃO usar `git reset --hard` sem autorização do Julio
