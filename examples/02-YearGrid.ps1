$module = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $module -Force
$year = New-BCYearGrid -Year 2028 -WeekStart Sunday -Layout Compact
$year.Months | Select-Object Year, Month, Rows
