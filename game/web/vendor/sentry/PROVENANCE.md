# Sentry JavaScript SDK (web build only)

`bundle.tracing.min.js` is Sentry's browser SDK 11.10.0, the errors and tracing bundle
("Performance Monitoring"), unchanged: https://browser.sentry-cdn.com/11.10.0/bundle.tracing.min.js
(158,404 bytes, released 2026-10-28), downloaded 2026-11-17. Its SHA-384,
`sha384-1QzQUgVRbZtBrqR50MvCo9tvVHw523MzC3b03wszECzzN7qPq1xEZxnsqLT3KDQl`, is the one
Sentry's release registry publishes for that file
(https://github.com/getsentry/sentry-release-registry, `packages/npm/@sentry/browser/11.10.0.json`).
`LICENSE` is `packages/browser/LICENSE` of https://github.com/getsentry/sentry-javascript at
the tag `11.10.0` (MIT, Functional Software, Inc. dba Sentry).

Only the web build uses it. `tools/build-web.sh` copies it beside the page as
`treasure-island-<commit>.sentry.js`, with this licence as
`treasure-island-<commit>.sentry.LICENSE.txt`, and gives the page its integrity hash;
the page loads it only when crash reports may be sent (`tiReporting` in
`game/web/shell.html`). Godot's export never packs it.

To update it: download the new version's `bundle.tracing.min.js` and its licence, check
the file against the registry's SHA-384 for it, read the SDK's migration notes for
changes to what it collects by default (11.0 made `dataCollection` collect everything
unless told otherwise), and check what the page's settings send with
`tools/check_web_reporting.mjs` and a browser run against a local stand-in endpoint.
