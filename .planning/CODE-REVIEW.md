# Code Review — Proposal Slides (propostawhite + propostadark)

**Reviewed:** 2026-04-27
**Files:** `propostawhite/index.html`, `propostadark/index.html`
**Depth:** Standard

---

## CRITICAL

### CR-01: Missing `@media print` — PDF generation broken (BOTH files)

**Files:** `propostawhite/index.html` (no print CSS), `propostadark/index.html` (no print CSS)

**Issue:** Neither file has `@media print` rules. When the user prints to PDF:
- `html,body { overflow: hidden }` clips all content to one page
- `position: absolute; opacity: 0` on non-active slides hides all slides except slide 1
- Result: PDF shows only Slide 1, everything else is invisible

**Fix — add to both files before `</style>`:**
```css
@media print {
  html, body { overflow: visible !important; height: auto !important; background: #fff; }
  #deck { position: static !important; height: auto !important; overflow: visible !important; }
  #counter, #dots { display: none !important; }
  .slide {
    position: relative !important;
    opacity: 1 !important;
    pointer-events: auto !important;
    width: 100% !important;
    height: 100vh !important;   /* one slide per page */
    page-break-after: always;
    break-after: page;
    overflow: hidden !important;
    display: flex !important;
  }
  /* White version: keep backgrounds */
  .cover-bg { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
  /* Dark version: force background colors */
  body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
}
```

---

### CR-02: Cover image path broken on dark version (propostadark)

**File:** `propostadark/index.html`, line 223
```css
background-image: url('../img/leadership-team.jpg');
```

**Issue:** `../img/` navigates one level up from `propostadark/`, pointing to `/empresa-inteligente/img/`. The file `/empresa-inteligente/img/leadership-team.jpg` **does exist**, so this is actually correct — but if the files are ever opened from a different directory context (e.g., served from root) or moved, it will silently break. Same applies to `propostawhite/index.html` line 117.

**Actual risk:** Low if files stay in their current directories, but the path is fragile. Document it.

**White version same path:** line 116 of `propostawhite/index.html` — same pattern, same risk.

---

## HIGH

### HR-01: Dot navigation uses `<div>` instead of `<button>` — keyboard/accessibility broken (propostadark)

**File:** `propostadark/index.html`, lines 997–1001
```js
const d = document.createElement('div');
d.className = 'dot' + (i === 0 ? ' active' : '');
d.addEventListener('click', () => goTo(i));
```

**Issue:** `<div>` elements are not focusable by keyboard. Tab navigation cannot reach dots. Screen readers cannot interact with them. The white version uses `<button>` (correct), but the dark version does not.

**Fix:**
```js
const d = document.createElement('button');
d.className = 'dot' + (i === 0 ? ' active' : '');
d.setAttribute('aria-label', 'Slide ' + (i + 1));
d.addEventListener('click', () => goTo(i));
```
Also add to CSS (dark version):
```css
.dot { border: none; padding: 0; cursor: pointer; }
```

---

### HR-02: `Space` key navigation missing in dark version

**File:** `propostadark/index.html`, lines 1021–1024
```js
document.addEventListener('keydown', e => {
  if(e.key === 'ArrowRight' || e.key === ' '){ e.preventDefault(); goTo(cur + 1); }
  if(e.key === 'ArrowLeft') goTo(cur - 1);
});
```

**Issue:** `Home` and `End` key shortcuts present in the white version are absent in the dark version. Minor but inconsistent UX.

**Fix — add to the keydown handler:**
```js
if(e.key === 'Home') goTo(0);
if(e.key === 'End') goTo(TOTAL - 1);
```

---

### HR-03: Noise texture uses inline SVG data URI — causes reflow on every paint (propostadark)

**File:** `propostadark/index.html`, lines 31–38
```css
body::after {
  background-image: url("data:image/svg+xml,...");
  background-size: 200px;
  z-index: 9998
}
```

**Issue:** `z-index: 9998` on the noise overlay sits below the counter (`z-index: 1000`) but the overlay is `position: fixed; inset: 0; pointer-events: none` — it covers the entire viewport. If any interactive element ever needs `z-index < 9998`, it will be blocked. The dots at `z-index: 1000` are fine because `pointer-events: none` is set, but it's a fragile pattern. Also the inline SVG data URI re-renders on every scroll/paint.

**Fix:** Use `z-index: 1` for the noise layer (it only needs to be above the slide backgrounds), or extract to a separate `.png` asset.
```css
body::after { z-index: 1; } /* not 9998 */
```

---

### HR-04: `s-two` slide overflows on mobile — `overflow: hidden` clips content (BOTH)

**File:** `propostawhite/index.html`, line 34 / `propostadark/index.html`, line 51
```css
.slide { overflow: hidden }
```

**Issue:** Slide 3 (`s-two`) uses `height: 100%` on both panels with `flex: 1`. On viewports shorter than ~600px, the two-panel layout stacks (correct via media query in dark version, missing in white version) but `.slide { overflow: hidden }` will clip content that overflows vertically. Users on mobile can't scroll within a slide.

**White version specific bug:** No responsive media query for `s-two` — the two panels remain side by side even on `max-width: 600px`.

**Fix for white version — add media query:**
```css
@media (max-width: 768px) {
  .s-two .two-wrap { flex-direction: column; }
  .s-two .panel { padding: 40px 28px; }
  .s-two .panel-left { border-right: none; border-bottom: 3px solid var(--red); }
}
```

---

### HR-05: `animating` guard in dark version blocks navigation for 380ms but transition is 350ms

**File:** `propostadark/index.html`, lines 1012–1019
```js
animating = true;
// ...
setTimeout(() => { animating = false; }, 380);
```

**Issue:** The CSS transition is `350ms`. The guard resets at `380ms`. This is fine (30ms buffer) but the white version has no animation guard at all — rapid keypresses can corrupt the slide counter if the user holds down arrow keys quickly (though the opacity transition masks this visually).

**Fix for white version — add guard:**
```js
var animating = false;
function go(n) {
  if (n < 0 || n >= total || animating) return;
  animating = true;
  slides[cur].classList.remove('active');
  cur = n;
  slides[cur].classList.add('active');
  updateUI();
  setTimeout(function() { animating = false; }, 400);
}
```

---

## MEDIUM

### MR-01: Counter element in white version loses styling when slide theme changes

**File:** `propostawhite/index.html`, lines 1030–1039
```js
counter.className = t === 'dark' ? 'dark' : t === 'red' ? 'red' : '';
```

**Issue:** When `t` is `'light'` or `'half'`, `counter.className` is set to `''`, which removes the `id`-based styling that relies on the element being `#counter`. This is fine because `#counter` CSS still applies via ID, but the logic is fragile — if a future dev adds a shared class to `#counter` in HTML, it would be wiped on first slide transition.

**Fix:** Use `dataset` or explicit class management:
```js
counter.className = '';
if (t === 'dark') counter.classList.add('dark');
if (t === 'red') counter.classList.add('red');
```

---

### MR-02: Slide 3 white version — `data-theme="half"` is handled nowhere in JS

**File:** `propostawhite/index.html`, lines 546, 1030–1039
```html
<section class="slide s-two" data-theme="half">
```
```js
counter.className = t === 'dark' ? 'dark' : t === 'red' ? 'red' : '';
```

**Issue:** `theme("half")` falls through to `''` — the counter gets light styling which may not contrast well against the dark right panel visible behind the counter. Not a crash, but the counter may be hard to read.

**Fix:** Treat `'half'` as `'dark'` for the counter:
```js
counter.className = (t === 'dark' || t === 'half') ? 'dark' : t === 'red' ? 'red' : '';
```
And do the same for dot color class logic.

---

### MR-03: WhatsApp number is a placeholder in white version CTA

**File:** `propostawhite/index.html`, line 1004
```html
<a href="https://wa.me/5511999999999">(11) 99999-9999</a>
```

**Issue:** This is a dummy number. When sent to prospects, clicking it will open an invalid WhatsApp chat. Needs to be replaced with the real number before distribution.

---

### MR-04: Slide 11 white version — metric "12 sem" has no unit clarity

**File:** `propostawhite/index.html`, line 915
```html
<span class="metric-num">12 sem</span>
```

**Issue:** "sem" is abbreviated Portuguese for "semanas" (weeks) but looks like English "sem" (without). The dark version has the same metric but shows "12" with a label "semanas do diagnóstico ao resultado" — cleaner. The white version truncation may confuse readers.

**Fix:**
```html
<span class="metric-num">12</span>
<p>semanas do diagnóstico ao resultado comprovado</p>
```

---

### MR-05: `s-cover` in white version — `.cover-content` is a sibling of `.cover-bg` and `.cover-overlay` but not inside `.slide-inner`

**File:** `propostawhite/index.html`, lines 131–160
```css
.s-cover .cover-content { position: relative; z-index: 2; width: 100%; max-width: 1160px; padding: 0 52px }
```

**Issue:** The `.logo-bar` and `.url-footer` use `position: absolute` relative to `.s-cover` (the slide). This is correct, but if `.s-cover` ever gets `overflow: hidden` tightened (already set on `.slide`), those elements could be clipped. Currently fine, but `.url-footer` at `bottom: 24px` with `left: 50%; transform: translateX(-50%)` is inside `.s-cover` which itself is `position: absolute; inset: 0` — it should be safe, but on mobile the `@media print` fix (CR-01) must ensure it doesn't overlap.

---

### MR-06: Dark version — `TOTAL` is hardcoded to `15`, not derived from DOM

**File:** `propostadark/index.html`, line 989
```js
const TOTAL = 15;
```

**Issue:** If a slide is added or removed from the HTML without updating this constant, the counter shows wrong totals, dots are miscounted, and navigation breaks. The white version derives `total` from `slides.length` (correct).

**Fix:**
```js
const slides = document.querySelectorAll('.slide');
const TOTAL = slides.length;
```

---

## LOW

### LR-01: Missing `role="group"` and `aria-label` on dots container (BOTH)

**File:** Both files, `#dots` div.

**Issue:** The dots navigation has no accessible label. Screen readers announce it as an unlabeled group.

**Fix:**
```html
<div id="dots" role="group" aria-label="Navegação de slides"></div>
```

---

### LR-02: `<blockquote>` in white version has no `cite` attribute

**File:** `propostawhite/index.html`, line 743
```html
<blockquote>A IA vai transformar...</blockquote>
```

**Issue:** Semantic HTML expects `<cite>` or `cite` attribute for quotations. Minor but semantically incorrect.

**Fix:**
```html
<blockquote cite="https://anthropic.com">...</blockquote>
```

---

### LR-03: Google Fonts loaded without `display=swap` fallback handling

**Files:** Both files, line 9.
```html
<link href="https://fonts.googleapis.com/css2?family=Zen+Dots&...&display=swap" rel="stylesheet">
```

**Issue:** `display=swap` is present (correct), but there's no `<noscript>` fallback and no system font stack defined for when Google Fonts is unavailable (offline demo, firewall, slow connection). The `font-family` declarations fall back to `sans-serif` which doesn't match the design.

**Fix:** Add a closer fallback:
```css
:root { font-family: 'Space Grotesk', 'Segoe UI', system-ui, sans-serif; }
h1, h2 { font-family: 'Zen Dots', 'Courier New', monospace; }
```

---

### LR-04: Commented-out `data-index` attributes serve no purpose in dark version

**File:** `propostadark/index.html`, every `<section>` element (lines 557, 586, 612, ...).
```html
<section class="slide s-cover active" data-index="0">
```

**Issue:** `data-index` is never read by the JavaScript — slides are queried with `querySelectorAll('.slide')` and indexed by DOM order. The attribute is dead data. Not harmful but clutters the HTML.

---

## Summary

| Severity | Count | Key issues |
|----------|-------|-----------|
| CRITICAL | 2 | No print CSS (PDF broken), image path fragility |
| HIGH | 5 | `<div>` dots (dark), no `Home`/`End` keys (dark), noise z-index, no mobile stacking (white), no animation guard (white) |
| MEDIUM | 6 | `data-theme="half"` unhandled, placeholder phone, hardcoded `TOTAL`, metric label unclear, counter class mutation |
| LOW | 4 | Aria labels, blockquote cite, font fallback, dead data-index |

**Most urgent fix before sharing with any prospect:** CR-01 (print/PDF), HR-03 (z-index noise), MR-03 (placeholder phone number).

---

_Reviewer: Claude Code (gsd-code-reviewer) — standard depth_
