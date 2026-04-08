// ==UserScript==
// @name         Ctrl-P / Ctrl-N Suggestion Navigation (YouTube + Google)
// @namespace    https://example.com/
// @version      1.1
// @description  Navigate search suggestions with Ctrl/Cmd+P (up) and Ctrl/Cmd+N (down) on YouTube and Google.
// @author       You
// @match        https://www.youtube.com/*
// @match        https://www.google.com/*
// @match        https://www.google.*/*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  function hostIsGoogle() {
    return /(^|\.)google\./i.test(location.hostname);
  }

  function hostIsYouTube() {
    return /(^|\.)youtube\.com$/i.test(location.hostname);
  }

  function getSearchInput() {
    if (hostIsYouTube()) {
      return (
        document.querySelector("input#search") ||
        document.querySelector('input[name="search_query"]')
      );
    }

    if (hostIsGoogle()) {
      // Main Google search input
      return (
        document.querySelector('textarea[name="q"]') || // newer Google often uses textarea
        document.querySelector('input[name="q"]')
      );
    }

    return null;
  }

  function sendArrowKey(key, target) {
    if (!target) return;

    const keyCode = key === "ArrowUp" ? 38 : 40;

    if (document.activeElement !== target) target.focus();

    // Some sites react better to keydown + keyup
    const down = new KeyboardEvent("keydown", {
      key,
      code: key,
      keyCode,
      which: keyCode,
      bubbles: true,
      cancelable: true,
    });

    const up = new KeyboardEvent("keyup", {
      key,
      code: key,
      keyCode,
      which: keyCode,
      bubbles: true,
      cancelable: true,
    });

    target.dispatchEvent(down);
    target.dispatchEvent(up);
  }

  function handler(e) {
    if (e.isComposing || e.defaultPrevented) return;

    const modifierDown = e.ctrlKey || e.metaKey; // Ctrl on Win/Linux, Cmd on macOS
    if (!modifierDown) return;

    const k = e.key;
    if (!["p", "P", "n", "N"].includes(k)) return;

    const searchInput = getSearchInput();
    if (!searchInput) return;

    // Only when focused in the search box
    if (document.activeElement !== searchInput) return;

    // Prevent page/site handlers. Note: browser-level Ctrl+P (print) can still win in Firefox/Chrome.
    e.preventDefault();
    e.stopPropagation();

    if (k.toLowerCase() === "p") sendArrowKey("ArrowUp", searchInput);
    if (k.toLowerCase() === "n") sendArrowKey("ArrowDown", searchInput);
  }

  document.addEventListener("keydown", handler, true);

  console.log("[Ctrl-P/N] Loaded for:", location.hostname);
})();
