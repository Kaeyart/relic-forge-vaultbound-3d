# 094A — UI Foundation Rewrite

This patch starts the actual UI rebuild by establishing shared rules:

- every panel gets a clear title
- every panel gets a short task explanation
- every panel gets a predictable action row
- every item detail can be rendered through one shared formatter
- panels start moving toward one interaction model:
  - click selects
  - double-click performs primary action where supported
  - right-click opens context where supported
  - bottom action bar exposes important actions
  - close is always available

This is a foundation patch, not the full final UI. The next patches should rebuild each panel on top of this base.
