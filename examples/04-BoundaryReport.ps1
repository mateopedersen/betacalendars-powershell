$module = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $module -Force
$report = Get-BCBoundaryReport -Year 2027
$report.MonthLengthChanges | Select-Object From, To, FromMonthDays, ToMonthDays
$report.ISOWeekYearTransitions
