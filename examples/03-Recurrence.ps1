$module = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $module -Force
Get-BCRecurrence -Pattern MonthlyDay -From '2024-01-01' -To '2024-06-30' -MaxOccurrences 10 -Day 31 -InvalidDayPolicy Skip
