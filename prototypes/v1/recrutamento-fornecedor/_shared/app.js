/* Comportamento comum às 5 telas: tema claro/escuro + drawer mobile/tablet. */
(function () {
  "use strict";

  var root = document.documentElement;
  var saved = localStorage.getItem("ei-theme");
  if (saved === "light" || saved === "dark") root.setAttribute("data-theme", saved);

  function currentTheme() {
    var attr = root.getAttribute("data-theme");
    if (attr) return attr;
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  function updateToggleLabel(btn) {
    var next = currentTheme() === "dark" ? "claro" : "escuro";
    var label = btn.querySelector(".theme-toggle-label");
    if (label) label.textContent = "Tema " + next;
  }

  document.querySelectorAll("[data-theme-toggle]").forEach(function (btn) {
    updateToggleLabel(btn);
    btn.addEventListener("click", function () {
      var next = currentTheme() === "dark" ? "light" : "dark";
      root.setAttribute("data-theme", next);
      localStorage.setItem("ei-theme", next);
      updateToggleLabel(btn);
    });
  });

  var sidebar = document.querySelector("[data-sidebar]");
  var backdrop = document.querySelector("[data-drawer-backdrop]");
  function closeDrawer() {
    if (sidebar) sidebar.setAttribute("data-open", "false");
    if (backdrop) backdrop.setAttribute("data-open", "false");
  }
  document.querySelectorAll("[data-drawer-toggle]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var open = sidebar && sidebar.getAttribute("data-open") === "true";
      if (sidebar) sidebar.setAttribute("data-open", String(!open));
      if (backdrop) backdrop.setAttribute("data-open", String(!open));
    });
  });
  if (backdrop) backdrop.addEventListener("click", closeDrawer);
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") closeDrawer();
  });
})();
