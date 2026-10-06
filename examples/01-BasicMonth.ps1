$module = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $module -Force
$grid = New-BCMonthGrid -Year 2027 -Month 1 -WeekStart Monday -Layout FixedSixWeeks
$grid.Cells | Select-Object Row, Column, Date, Weekday, InMonth, IsWeekend
