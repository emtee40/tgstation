/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
(function () {
  'use strict';

  // Inferno needs Int32Array, and it is not covered by core-js.
  if (!window.Int32Array) {
    window.Int32Array = Array;
  }

  !(function () {
    function t() {
      var e = Array.prototype.slice.call(arguments),
        n = document.createDocumentFragment();
      e.forEach(function (e) {
        var t = e instanceof Node;
        n.appendChild(t ? e : document.createTextNode(String(e)));
      }),
        this.appendChild(n);
    }
    [Element.prototype, Document.prototype, DocumentFragment.prototype].forEach(
      function (e) {
        e.hasOwnProperty('append') ||
          Object.defineProperty(e, 'append', {
            configurable: !0,
            enumerable: !0,
            writable: !0,
            value: t,
          });
      }
    );
  })();
})();
