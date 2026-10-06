# Contributing

Use PowerShell 7.4 or later. Keep calendar calculations deterministic,
timezone-independent, and offline. Add Pester coverage for changed behavior and
run PSScriptAnalyzer before opening a pull request.

```powershell
Test-ModuleManifest ./src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning
Invoke-Pester ./tests
```

Changes to a published version require a new semantic version.

PSScriptAnalyzer may report `PSUseShouldProcessForStateChangingFunctions` for
`New-BCMonthGrid`, `New-BCYearGrid`, and `New-BCYearTurnFixture`. Those findings
are intentionally accepted: the functions return in-memory data and perform no
external state changes, so `-WhatIf` would not represent a meaningful operation.
