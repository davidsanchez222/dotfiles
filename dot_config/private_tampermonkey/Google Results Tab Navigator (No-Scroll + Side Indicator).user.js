// ==UserScript==
// @name         Google Results Tab Navigator (No-Scroll + Side Indicator)
// @namespace    https://tampermonkey.net/
// @version      1.1.0
// @description  Tab / Shift+Tab cycles Google results without scrolling unless needed; side indicator like Google keyboard shortcuts. Enter opens selected.
// @match        https://www.google.*/*search*
// @match        https://www.google.com/*search*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  // --- Settings ---
  const SETTINGS = {
    // If true: Enter opens selected result in a new tab. If false: same tab.
    openInNewTab: false,

    // If next selected result is within the viewport, do NOT scroll at all.
    // If it is outside the viewport, scroll just enough to bring it into view.
    scrollBehavior: "smooth", // "auto" | "smooth"

    // How much padding to keep from viewport edges when scrolling into view
    viewportPaddingPx: 16,
  };

  // --- Styling (side indicator) ---
  const STYLE_ID = "tm-google-tabnav-style-v2";
  const ACTIVE_ATTR = "data-tm-tabnav-active";

  function injectStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      /* Ensure container can anchor a left-side indicator */
      [${ACTIVE_ATTR}="1"] {
        position: relative !important;
      }

      /* Left-side indicator bar (similar vibe to Google keyboard nav) */
      [${ACTIVE_ATTR}="1"]::before {
        content: "";
        position: absolute;
        left: -12px;
        top: 10px;
        bottom: 10px;
        width: 4px;
        border-radius: 999px;
        background: #1a73e8;
      }

      /* Optional subtle cue without "highlighting the whole result" */
      [${ACTIVE_ATTR}="1"] {
        /* tiny shadow on the left edge only */
        box-shadow: -2px 0 0 rgba(26,115,232,0.20) !important;
      }
    `;
    document.head.appendChild(style);
  }

  // --- Utilities ---
  function isEditableTarget(target) {
    if (!target) return false;
    const tag = (target.tagName || "").toLowerCase();
    return target.isContentEditable || tag === "input" || tag === "textarea" || tag === "select";
  }

  function closestResultContainer(a) {
    // Try to pick the visual "card" so the indicator sits next to the result.
    return (
      a.closest("div.MjjYud") || // common organic result wrapper
      a.closest("div.g") ||      // legacy wrapper
      a.closest("div.tF2Cxc") || // legacy wrapper
      a.closest("div.Gx5Zad") || // mobile-ish wrapper sometimes
      a.closest("div")           // fallback
    );
  }

  function collectOrganicResults() {
    // Typical organic result: <a> containing an <h3>
    const anchors = Array.from(document.querySelectorAll("a:has(h3)"));
    return anchors
      .map((a) => {
        const href = a.getAttribute("href") || "";
        if (!href || href.startsWith("#")) return null;

        const h3 = a.querySelector("h3");
        if (!h3) return null;

        const container = closestResultContainer(a);
        if (!container) return null;

        return { link: a, container };
      })
      .filter(Boolean);
  }

  function uniqueByHref(items) {
    const seen = new Set();
    const out = [];
    for (const it of items) {
      const href = it?.link?.href;
      if (!href || seen.has(href)) continue;
      seen.add(href);
      out.push(it);
    }
    return out;
  }

  function getResults() {
    // You asked specifically for Google search results; keep it simple/organic.
    return uniqueByHref(collectOrganicResults()).slice(0, 200);
  }

  function clearActive() {
    document.querySelectorAll(`[${ACTIVE_ATTR}="1"]`).forEach((el) => {
      el.removeAttribute(ACTIVE_ATTR);
    });
  }

  function isElementOffscreen(el, paddingPx = 0) {
    const r = el.getBoundingClientRect();
    const topBound = 0 + paddingPx;
    const bottomBound = window.innerHeight - paddingPx;

    // Consider "offscreen" if any meaningful part is outside padded viewport.
    return r.top < topBound || r.bottom > bottomBound;
  }

  function scrollIntoViewIfNeeded(el) {
    if (!el) return;

    if (!isElementOffscreen(el, SETTINGS.viewportPaddingPx)) {
      // Requirement #1: do NOT scroll if it's already on-screen
      return;
    }

    // Scroll just enough. scrollIntoView tends to be "minimal" in most browsers.
    // Use 'nearest' to avoid centering/jumping.
    el.scrollIntoView({
      behavior: SETTINGS.scrollBehavior,
      block: "nearest",
      inline: "nearest",
    });
  }

  // --- Navigation state ---
  let results = [];
  let index = -1;

  function refreshResults() {
    results = getResults();
    if (!results.length) {
      index = -1;
      return false;
    }
    if (index >= results.length) index = results.length - 1;
    return true;
  }

  function setActive(i) {
    if (!results.length) return null;

    index = (i + results.length) % results.length;
    const item = results[index];

    clearActive();
    item.container.setAttribute(ACTIVE_ATTR, "1");

    // Requirement #1: only scroll if needed
    scrollIntoViewIfNeeded(item.container);

    return item;
  }

  function step(dir) {
    if (!refreshResults()) return;

    if (index === -1) setActive(0);
    else setActive(index + dir);
  }

  function openActive() {
    if (!refreshResults() || index === -1) return;
    const href = results[index].link.href;
    if (!href) return;

    if (SETTINGS.openInNewTab) {
      window.open(href, "_blank", "noopener,noreferrer");
    } else {
      window.location.href = href;
    }
  }

  // --- Mutation observer (keeps results list fresh on dynamic changes) ---
  const observer = new MutationObserver(() => {
    if (observer._tmTimer) clearTimeout(observer._tmTimer);
    observer._tmTimer = setTimeout(() => {
      const prevHref = results[index]?.link?.href;
      refreshResults();

      // Try to keep selection on the same href after refresh
      if (prevHref) {
        const newIdx = results.findIndex((r) => r.link.href === prevHref);
        if (newIdx !== -1) {
          index = newIdx;
          clearActive();
          results[index].container.setAttribute(ACTIVE_ATTR, "1");
        }
      }
    }, 200);
  });

  function startObserving() {
    observer.observe(document.body, { childList: true, subtree: true });
  }

  // --- Key handling ---
  function onKeyDown(e) {
    if (isEditableTarget(e.target)) return;
    if (e.ctrlKey || e.metaKey || e.altKey) return;

    if (e.key === "Tab") {
      e.preventDefault();
      step(e.shiftKey ? -1 : 1);
      return;
    }

    if (e.key === "Enter") {
      if (index === -1) {
        if (refreshResults()) setActive(0);
        return;
      }
      e.preventDefault();
      openActive();
      return;
    }

    if (e.key === "Escape") {
      clearActive();
      index = -1;
    }
  }

  // --- Init ---
  injectStyles();
  refreshResults();
  startObserving();
  window.addEventListener("keydown", onKeyDown, true);
})();
