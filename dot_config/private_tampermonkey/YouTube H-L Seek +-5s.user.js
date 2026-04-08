// ==UserScript==
// @name         YouTube H/L Seek ±5s
// @namespace    https://tampermonkey.net/
// @version      1.0
// @description  Map h and l keys to -5s and +5s seek on YouTube videos
// @author       you
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @run-at       document-end
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    function isTypingElement(el) {
        if (!el) return false;
        const tag = el.tagName ? el.tagName.toLowerCase() : '';
        const editable = el.isContentEditable;
        return (
            editable ||
            tag === 'input' ||
            tag === 'textarea' ||
            el.closest('input, textarea, [contenteditable="true"]')
        );
    }

    function seek(seconds) {
        const video = document.querySelector('video');
        if (!video) return;
        // Clamp at 0 just in case
        video.currentTime = Math.max(0, video.currentTime + seconds);
    }

    window.addEventListener('keydown', function (e) {
        // Don't interfere with other handlers if default is already prevented
        if (e.defaultPrevented) return;

        // Skip when user is typing in a text field / comment box, etc.
        if (isTypingElement(e.target)) return;

        if (e.key === 'h' || e.key === 'H') {
            seek(-5);             // -5 seconds
            e.preventDefault();
            e.stopPropagation();
        } else if (e.key === 'l' || e.key === 'L') {
            seek(5);              // +5 seconds
            e.preventDefault();
            e.stopPropagation();
        }
    }, true); // capture phase so we beat YouTube's own handler if needed
})();
