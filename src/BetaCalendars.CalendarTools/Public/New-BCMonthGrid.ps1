function New-BCMonthGrid {
    <#
    .SYNOPSIS
    Creates a structured Gregorian month grid.
    .DESCRIPTION
    Returns row-major cell objects. FixedSixWeeks always has 42 cells. Blank overflow keeps weekday/position metadata and has a null Date.
    .PARAMETER Year
    Gregorian year from 1 through 9999.
    .PARAMETER Month
    Gregorian month number from 1 through 12.
    .PARAMETER WeekStart
    Weekday shown in the first grid column.
    .PARAMETER Layout
    FixedSixWeeks for exactly 42 cells, or Compact for the minimum number of rows.
    .PARAMETER Overflow
    Adjacent for actual neighboring dates, or Blank for null dates outside the month.
    .PARAMETER SpecialDate
    Optional caller-supplied civil dates marked on matching cells; no holiday database is used.
    .EXAMPLE
    (New-BCMonthGrid -Year 2027 -Month 1).Cells | Where-Object InMonth
    .INPUTS
    None. Parameters are supplied by name or position.
    .OUTPUTS
    BetaCalendars.CalendarTools.MonthGrid
    .NOTES
    Calculations use timezone-independent Gregorian civil dates.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][ValidateRange(1,9999)][int]$Year,
        [Parameter(Mandatory,Position=1)][ValidateRange(1,12)][int]$Month,
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')][string]$WeekStart='Monday',
        [ValidateSet('FixedSixWeeks','Compact')][string]$Layout='FixedSixWeeks',
        [ValidateSet('Adjacent','Blank')][string]$Overflow='Adjacent',
        [datetime[]]$SpecialDate=@()
    )
    $cells = @(Get-BCGridCells -Year $Year -Month $Month -WeekStart $WeekStart -Layout $Layout -Overflow $Overflow -SpecialDate $SpecialDate)
    [pscustomobject][ordered]@{
        PSTypeName='BetaCalendars.CalendarTools.MonthGrid'
        Year=$Year; Month=$Month; WeekStart=$WeekStart; Layout=$Layout; Overflow=$Overflow
        Rows=[int]($cells.Count / 7); Cells=$cells
    }
}
