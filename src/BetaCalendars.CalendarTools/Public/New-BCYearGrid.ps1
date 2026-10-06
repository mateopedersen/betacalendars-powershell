function New-BCYearGrid {
    <#
    .SYNOPSIS
    Creates the twelve month grids for a Gregorian year.
    .DESCRIPTION
    Builds each month using the same week-start, layout, and overflow settings.
    .PARAMETER Year
    Gregorian year from 1 through 9999.
    .PARAMETER WeekStart
    Weekday shown in the first grid column of every month.
    .PARAMETER Layout
    FixedSixWeeks or Compact.
    .PARAMETER Overflow
    Adjacent or Blank.
    .EXAMPLE
    (New-BCYearGrid -Year 2027).Months.Count
    .INPUTS
    None.
    .OUTPUTS
    BetaCalendars.CalendarTools.YearGrid
    .NOTES
    All twelve grids are computed offline from the Gregorian calendar.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateRange(1,9999)][int]$Year,
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')][string]$WeekStart='Monday',
        [ValidateSet('FixedSixWeeks','Compact')][string]$Layout='FixedSixWeeks',
        [ValidateSet('Adjacent','Blank')][string]$Overflow='Adjacent'
    )
    $months = for ($month=1; $month -le 12; $month++) { New-BCMonthGrid -Year $Year -Month $month -WeekStart $WeekStart -Layout $Layout -Overflow $Overflow }
    [pscustomobject][ordered]@{ PSTypeName='BetaCalendars.CalendarTools.YearGrid'; Year=$Year; Months=@($months) }
}
