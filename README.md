# BetaCalendars.CalendarTools

Offline PowerShell tools for civil-date calculations, structured calendar
grids, bounded recurrence, and temporal regression fixtures.

```powershell
Install-Module BetaCalendars.CalendarTools
Import-Module BetaCalendars.CalendarTools

$january = New-BCMonthGrid -Year 2027 -Month 1 -WeekStart Monday
$january.Cells.Count # 42
New-BCYearTurnFixture -Year 2026 | Select-Object Year, MonthName, DaysInMonth
```

## What it provides

- `New-BCMonthGrid`: fixed 42-cell or compact grids, all seven week starts,
  adjacent or blank overflow, ISO week metadata, and caller-marked special dates.
- `New-BCYearGrid`: twelve month grids with shared options.
- `Get-BCDateRange`: inclusive, consecutive civil dates.
- `Get-BCRecurrence`: bounded daily, weekly, monthly-day, nth-weekday,
  last-weekday, and annual rules; not an RFC 5545 implementation.
- `Get-BCBoundaryReport`: month lengths, year turns, leap days, and ISO week-year
  boundaries for temporal regression work.
- `New-BCYearTurnFixture`: November through February across a year boundary.
- `Export-BCCalendarFixture`: JSON, CSV, or Markdown output.
- `Test-BCCalendarInvariant`: structured invariant results for CI.

The module uses only PowerShell and .NET built-ins. Date inputs are interpreted
as civil dates: time components are removed and no time zone, network call,
telemetry, or external holiday service is involved. Special dates are supplied
by the caller; the module does not include a holiday authority or database.

See [Year-turn regression testing](src/BetaCalendars.CalendarTools/docs/YearTurn-Testing.md)
for the four-month boundary case and its visual reference calendars.

## Development

Requires PowerShell 7.4 or later. Import the module from
`src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1`.

```powershell
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning
Invoke-Pester ./tests
Test-ModuleManifest ./src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1
```

## License

MIT. See [LICENSE](LICENSE).
