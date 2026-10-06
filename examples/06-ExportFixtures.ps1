$module = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $module -Force
New-BCYearTurnFixture -Year 2026 | Export-BCCalendarFixture -Format Markdown
