function New-BCYearTurnFixture {
    <#
    .SYNOPSIS
    Creates a November-through-February cross-year calendar fixture.
    .DESCRIPTION
    Given year Y, returns November and December of Y, then January and February of Y+1. These grids are suitable for regression and boundary tests.
    .PARAMETER Year
    Starting Gregorian year from 1 through 9998.
    .PARAMETER WeekStart
    Weekday shown in the first grid column.
    .PARAMETER Layout
    FixedSixWeeks or Compact.
    .PARAMETER Overflow
    Adjacent or Blank.
    .EXAMPLE
    New-BCYearTurnFixture -Year 2026 | Select-Object Year,Month,DaysInMonth
    .INPUTS
    None.
    .OUTPUTS
    Four fixture objects, each containing a MonthGrid.
    .NOTES
    February length is calculated for the following year and follows Gregorian leap rules.
    .LINK
    Get-BCBoundaryReport
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateRange(1,9998)][int]$Year,
          [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')][string]$WeekStart='Monday',
          [ValidateSet('FixedSixWeeks','Compact')][string]$Layout='FixedSixWeeks',
          [ValidateSet('Adjacent','Blank')][string]$Overflow='Adjacent')
    $periods=@(
        [pscustomobject]@{Year=$Year;Month=11},
        [pscustomobject]@{Year=$Year;Month=12},
        [pscustomobject]@{Year=($Year+1);Month=1},
        [pscustomobject]@{Year=($Year+1);Month=2}
    )
    foreach ($period in $periods) {
        $grid=New-BCMonthGrid -Year $period.Year -Month $period.Month -WeekStart $WeekStart -Layout $Layout -Overflow $Overflow
        [pscustomobject][ordered]@{ Year=$period.Year; Month=$period.Month; MonthName=([cultureinfo]::InvariantCulture.DateTimeFormat.GetMonthName($period.Month)); DaysInMonth=[datetime]::DaysInMonth($period.Year,$period.Month); Grid=$grid }
    }
}
