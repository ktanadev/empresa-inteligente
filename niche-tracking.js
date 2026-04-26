/* Empresa Inteligente — Niche LP Tracking v2.0
 * GTM-compatible dataLayer events per section, dept, scroll, CTA
 * v2.0: UTM pass-through to /diagnostico + direct Google Ads conversion on CTA click
 */
(function () {
  'use strict';
  window.dataLayer = window.dataLayer || [];
  var NICHO = document.body.dataset.nicho || 'unknown';

  // --- Google Ads direct conversion (P0.2) ---
  var AW_ID = 'AW-17974237978';
  var MQL_CONVERSION = 'AW-17974237978/DfQ2CKrLip8cEJq25PpC';
  var gtagLoaded = false;
  function loadGtag(callback) {
    if (gtagLoaded || window.gtag) { gtagLoaded = true; callback && callback(); return; }
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.googletagmanager.com/gtag/js?id=' + AW_ID;
    s.onload = function () {
      window.dataLayer = window.dataLayer || [];
      window.gtag = window.gtag || function () { dataLayer.push(arguments); };
      gtag('js', new Date());
      gtag('config', AW_ID, { allow_enhanced_conversions: true });
      gtagLoaded = true;
      callback && callback();
    };
    document.head.appendChild(s);
  }
  function fireMQLConversion() {
    loadGtag(function () {
      gtag('event', 'conversion', { send_to: MQL_CONVERSION });
    });
  }

  // --- UTM pass-through (P1.1) ---
  function getUTMs() {
    var params = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'gclid', 'fbclid'];
    var result = [];
    var search = location.search;
    params.forEach(function (p) {
      var match = search.match(new RegExp('[?&]' + p + '=([^&]*)'));
      if (match) result.push(p + '=' + match[1]);
    });
    return result.join('&');
  }
  function injectUTMs() {
    var utmStr = getUTMs();
    if (!utmStr) return;
    document.querySelectorAll('a[href]').forEach(function (a) {
      var href = a.getAttribute('href');
      if (!href) return;
      // Match absolute + relative /diagnostico links
      if (href.indexOf('/diagnostico') !== -1 || href.indexOf('empresainteligente.ai/diagnostico') !== -1) {
        var sep = href.indexOf('?') !== -1 ? '&' : '?';
        a.setAttribute('href', href + sep + utmStr);
      }
    });
  }

  // 1. Page view
  dataLayer.push({ event: 'ei_page_view', nicho: NICHO, page_title: document.title, page_url: location.pathname });

  // 2. Section view (fires once per section, when 40% visible)
  var sectionObs = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        var pct = Math.round((window.scrollY + window.innerHeight) / Math.max(document.body.scrollHeight, 1) * 100);
        dataLayer.push({ event: 'ei_section_view', nicho: NICHO, section: entry.target.dataset.section, scroll_pct: pct });
        sectionObs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.4 });

  // 3. Dept card view (fires once per card, when 50% visible)
  var deptObs = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        dataLayer.push({ event: 'ei_dept_view', nicho: NICHO, dept: entry.target.dataset.dept });
        deptObs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  // 4. Scroll depth milestones
  var milestones = [25, 50, 75, 90, 100];
  var reached = [];
  window.addEventListener('scroll', function () {
    var pct = Math.round((window.scrollY + window.innerHeight) / Math.max(document.body.scrollHeight, 1) * 100);
    milestones.forEach(function (m) {
      if (pct >= m && reached.indexOf(m) === -1) {
        reached.push(m);
        dataLayer.push({ event: 'ei_scroll_depth', nicho: NICHO, depth: m });
      }
    });
  }, { passive: true });

  // 5. CTA clicks (delegated) + direct Google Ads MQL conversion
  document.addEventListener('click', function (e) {
    var cta = e.target.closest('[data-cta]');
    if (cta) {
      dataLayer.push({ event: 'ei_cta_click', nicho: NICHO, cta_id: cta.dataset.cta, cta_text: cta.textContent.trim().slice(0, 60) });
      // P0.2: fire direct Google Ads conversion on every CTA click
      fireMQLConversion();
    }
  });

  // 6. Time on page milestones
  var timeMilestones = [30, 60, 120, 180];
  var timeReached = [];
  timeMilestones.forEach(function (t) {
    setTimeout(function () {
      if (timeReached.indexOf(t) === -1) {
        timeReached.push(t);
        dataLayer.push({ event: 'ei_time_on_page', nicho: NICHO, seconds: t });
      }
    }, t * 1000);
  });

  // Init observers + UTM injection after DOM ready
  function initObservers() {
    document.querySelectorAll('[data-section]').forEach(function (s) { sectionObs.observe(s); });
    document.querySelectorAll('[data-dept]').forEach(function (d) { deptObs.observe(d); });
    injectUTMs();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initObservers);
  } else {
    initObservers();
  }
})();
