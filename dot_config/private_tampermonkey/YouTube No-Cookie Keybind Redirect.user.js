// ==UserScript==
// @name         YouTube No-Cookie Keybind Redirect
// @namespace    http://tampermonkey.net/
// @version      1.3
// @description  Press a keybind on a YouTube video page to switch youtube.com to yout-ube.com
// @match        *://*.youtube.com/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // Mac-safe default: Control + Shift + Y
    const REQUIRED_CODE = 'KeyY';
    const REQUIRE_ALT = false;
    const REQUIRE_SHIFT = true;
    const REQUIRE_CTRL = false;
    const REQUIRE_META = true;

    function isYouTubeVideoPage(input) {
        const url = input instanceof URL ? input : new URL(input);

        return (
            /(^|\.)youtube\.com$/i.test(url.hostname) &&
            url.pathname === '/watch' &&
            url.searchParams.has('v')
        );
    }

    function redirectToNoCookieDomain() {
        const url = new URL(window.location.href);

        if (!isYouTubeVideoPage(url)) return;

        url.hostname = url.hostname.replace(/youtube\.com$/i, 'yout-ube.com');
        window.location.href = url.toString();
    }

    function matchesKeybind(event) {
        return (
            event.code === REQUIRED_CODE &&
            event.altKey === REQUIRE_ALT &&
            event.shiftKey === REQUIRE_SHIFT &&
            event.ctrlKey === REQUIRE_CTRL &&
            event.metaKey === REQUIRE_META
        );
    }

    document.addEventListener('keydown', (event) => {
        const target = event.target;
        const isTypingTarget =
            target &&
            (
                target.tagName === 'INPUT' ||
                target.tagName === 'TEXTAREA' ||
                target.isContentEditable
            );

        if (isTypingTarget) return;

        if (matchesKeybind(event)) {
            event.preventDefault();
            event.stopPropagation();
            redirectToNoCookieDomain();
        }
    }, true);
})();