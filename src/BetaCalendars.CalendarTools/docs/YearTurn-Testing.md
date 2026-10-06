# Year-turn regression fixture

`New-BCYearTurnFixture -Year Y` returns November and December in `Y`, followed
by January and February in `Y + 1`. The same fixture exercises a 30-day month,
a 31-day month, the December-to-January rollover, January's 31 days, and the
leap-year-dependent length of February.

```powershell
$fixture = @(New-BCYearTurnFixture -Year 2026)
$fixture | Select-Object Year, MonthName, DaysInMonth
```

The expected lengths are 30, 31, 31, and 28 for the 2026–2027 window. For
`-Year 2027`, February 2028 contains 29 days. The fixture is computed from the
Gregorian calendar and is not specific to those examples.

For visual comparison with the generated grids, these human-readable reference
calendars cover the same window:

- [November 2026](https://www.betacalendars.com/november-calendar.html)
- [December 2026](https://www.betacalendars.com/december-calendar.html)
- [January 2027](https://www.betacalendars.com/january-calendar.html)
- [February 2027](https://www.betacalendars.com/february-calendar.html)

## Date-only semantics

The module calculates Gregorian civil dates without a time zone or current-time
dependency. Inputs accepted as `DateTime` have their time portion discarded.
Overflow cells in an adjacent-date grid are actual consecutive dates; blank
overflow cells retain row, column, and weekday while exposing a null date.

## Other boundary checks

`Get-BCBoundaryReport -Year 2027` includes month transitions, changes in month
length, the following year turn, leap-day context, and ISO week-year transitions.
Use `Test-BCCalendarInvariant` in CI to check six-week geometry, date uniqueness,
adjacent overflow continuity, and twelve-month year output.
