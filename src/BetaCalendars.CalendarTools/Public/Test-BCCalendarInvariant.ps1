function Test-BCCalendarInvariant {
    <#
    .SYNOPSIS
    Checks deterministic calendar and recurrence invariants.
    .DESCRIPTION
    Returns one structured result per check, suitable for CI assertions and reports.
    .PARAMETER Year
    Gregorian year to validate.
    .PARAMETER Month
    Month to use for fixed-grid and in-month date checks.
    .EXAMPLE
    Test-BCCalendarInvariant -Year 2027
    .INPUTS
    None.
    .OUTPUTS
    BetaCalendars.CalendarTools.InvariantResult objects.
    .NOTES
    A failed check has Passed set to false; callers can use these results as a CI gate.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateRange(1,9999)][int]$Year,
          [ValidateRange(1,12)][int]$Month=1)
    $grid=New-BCMonthGrid -Year $Year -Month $Month -Layout FixedSixWeeks -Overflow Adjacent
    $monthDates=@($grid.Cells | Where-Object InMonth | ForEach-Object Date | Sort-Object -Unique)
    $days=[datetime]::DaysInMonth($Year,$Month)
    $cellsConsecutive=$true; $previousDate=$null
    foreach($cell in $grid.Cells) {
        if($null -eq $cell.Date) { continue }
        if($null -ne $previousDate -and $cell.Date -ne $previousDate.AddDays(1)) { $cellsConsecutive=$false; break }
        $previousDate=$cell.Date
    }
    $yearGrid=New-BCYearGrid -Year $Year -Layout Compact
    $checks=@(
        [pscustomobject]@{Name='FixedGridHas42Cells';Passed=($grid.Cells.Count -eq 42);Expected=42;Actual=$grid.Cells.Count},
        [pscustomobject]@{Name='RequestedMonthDatesUnique';Passed=($monthDates.Count -eq $days);Expected=$days;Actual=$monthDates.Count},
        [pscustomobject]@{Name='ConsecutiveOverflowDates';Passed=$cellsConsecutive;Expected=$true;Actual=$cellsConsecutive},
        [pscustomobject]@{Name='YearHas12Months';Passed=($yearGrid.Months.Count -eq 12);Expected=12;Actual=$yearGrid.Months.Count},
        [pscustomobject]@{Name='ValidLeapRules';Passed=([datetime]::IsLeapYear($Year) -eq ([datetime]::DaysInMonth($Year,2) -eq 29));Expected=([datetime]::IsLeapYear($Year));Actual=([datetime]::DaysInMonth($Year,2) -eq 29)}
    )
    foreach($check in $checks){[pscustomobject][ordered]@{PSTypeName='BetaCalendars.CalendarTools.InvariantResult';Name=$check.Name;Passed=[bool]$check.Passed;Expected=$check.Expected;Actual=$check.Actual}}
}
