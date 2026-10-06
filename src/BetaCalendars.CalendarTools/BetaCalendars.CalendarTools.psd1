@{
    RootModule = 'BetaCalendars.CalendarTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a7d558f9-a0c1-4b1e-8fb8-7cbec23e743c'
    Author = 'Beta Calendars'
    CompanyName = 'Beta Calendars'
    Copyright = '(c) 2026 Beta Calendars. All rights reserved.'
    Description = 'Offline PowerShell tools for deterministic calendar grids, bounded civil-date recurrence, serialization, and temporal boundary regression testing.'
    PowerShellVersion = '7.4'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'New-BCMonthGrid','New-BCYearGrid','Get-BCDateRange','Get-BCRecurrence',
        'Get-BCBoundaryReport','New-BCYearTurnFixture','Export-BCCalendarFixture',
        'Test-BCCalendarInvariant'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell','Calendar','Date','Recurrence','Testing','Automation','PSEdition_Core')
            LicenseUri = 'https://github.com/mateopedersen/betacalendars-powershell/blob/v1.0.0/LICENSE'
            ProjectUri = 'https://www.betacalendars.com/'
            ReleaseNotes = 'Initial stable release with civil-date grids, bounded recurrence, boundary reports, year-turn fixtures, deterministic exports, and invariant checks.'
        }
    }
}
