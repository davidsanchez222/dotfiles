// ==UserScript==
// @name         YouTube Tab Through Thumbnails (Videos + Playlists)
// @namespace    https://example.com/
// @version      1.3
// @description  Use Tab / Shift+Tab to move focus between YouTube video + playlist thumbnails.
// @author       You
// @match        https://www.youtube.com/results*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  function isTextInput(el) {
    if (!el) return false;
    if (el.isContentEditable) return true;
    const tag = el.tagName;
    if (!tag) return false;
    if (tag === "INPUT") {
      const type = (el.getAttribute("type") || "").toLowerCase();
      return !["checkbox", "radio", "button", "submit", "reset", "file"].includes(type);
    }
    return tag === "TEXTAREA";
  }

  function getThumbnailLinks() {
    // Video thumbnails + playlist/mix thumbnails
    const selectors = [
      "ytd-video-renderer a#thumbnail",
      "ytd-rich-item-renderer a#thumbnail",
      "yt-lockup-view-model a.yt-lockup-view-model__content-image"
    ];

    const links = Array.from(
      document.querySelectorAll(selectors.join(", "))
    ).filter((a) => a.offsetParent !== null); // visible only

    // Dedupe in case of overlap
    return Array.from(new Set(links));
  }

  function handleTabNavigation(e) {
    // Only plain Tab / Shift+Tab (no Ctrl/Alt/Meta)
    if (e.key !== "Tab" || e.ctrlKey || e.metaKey || e.altKey) return;

    const target = e.target;
    const typing = isTextInput(target);

    const thumbLinks = getThumbnailLinks();
    if (!thumbLinks.length) return;

    const activeThumb = target.closest
      ? target.closest(
          "ytd-video-renderer a#thumbnail, " +
          "ytd-rich-item-renderer a#thumbnail, " +
          "yt-lockup-view-model a.yt-lockup-view-model__content-image"
        )
      : null;

    // If you're typing in a text field that isn't on a thumbnail, let Tab behave normally
    if (typing && !activeThumb) {
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    let index = -1;
    if (activeThumb) {
      index = thumbLinks.indexOf(activeThumb);
    }

    const direction = e.shiftKey ? -1 : 1;
    const len = thumbLinks.length;

    let nextIndex;
    if (index === -1) {
      // Not currently on a thumbnail: start at first or last depending on direction
      nextIndex = direction === 1 ? 0 : len - 1;
    } else {
      nextIndex = (index + direction + len) % len;
    }

    const nextThumb = thumbLinks[nextIndex];
    if (!nextThumb) return;

    nextThumb.focus({ preventScroll: false });
    nextThumb.scrollIntoView({ block: "center", inline: "nearest" });
  }

  document.addEventListener("keydown", handleTabNavigation, true);
})();
