function Get-BCBoundaryReport {
    <#
    .SYNOPSIS
    Reports month, year, leap-day, and ISO week-year transitions.
    .DESCRIPTION
    Returns month-end transitions, month-length changes, the following year turn when representable, leap-day context, and ISO week-year changes touching the requested year.
    .PARAMETER Year
    Gregorian year from 1 through 9999.
    .EXAMPLE
    Get-BCBoundaryReport -Year 2027
    .INPUTS
    None.
    .OUTPUTS
    BetaCalendars.CalendarTools.BoundaryReport
    .NOTES
    Useful for deterministic temporal regression fixtures.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateRange(1,9999)][int]$Year)
    $monthTransitions = for ($month=1; $month -le 11; $month++) {
        $from=[datetime]::new($Year,$month,[datetime]::DaysInMonth($Year,$month)); $to=$from.AddDays(1)
        [pscustomobject][ordered]@{ Type='MonthTransition'; From=$from; To=$to; FromMonthDays=[datetime]::DaysInMonth($Year,$month); ToMonthDays=[datetime]::DaysInMonth($Year,$month+1); MonthLengthChanged=([datetime]::DaysInMonth($Year,$month) -ne [datetime]::DaysInMonth($Year,$month+1)); YearChanged=$false }
    }
    $hasYearTransition=$Year -lt 9999
    if ($hasYearTransition) {
        $from=[datetime]::new($Year,12,31); $to=$from.AddDays(1)
        $monthTransitions += [pscustomobject][ordered]@{ Type='MonthTransition'; From=$from; To=$to; FromMonthDays=31; ToMonthDays=31; MonthLengthChanged=$false; YearChanged=$true }
    }
    $isoChanges = [Collections.Generic.List[object]]::new()
    $yearStart=[datetime]::new($Year,1,1)
    $day=if($Year -gt 1){$yearStart.AddDays(-1)}else{$yearStart}
    while ($day.Year -le $Year -and $day -lt [datetime]::MaxValue.Date) {
        $next=$day.AddDays(1)
        if ([Globalization.ISOWeek]::GetYear($day) -ne [Globalization.ISOWeek]::GetYear($next)) { $isoChanges.Add([pscustomobject]@{Before=$day;After=$next;BeforeISOWeekYear=[Globalization.ISOWeek]::GetYear($day);AfterISOWeekYear=[Globalization.ISOWeek]::GetYear($next)}) }
        $day=$next
    }
    [pscustomobject][ordered]@{
        PSTypeName='BetaCalendars.CalendarTools.BoundaryReport'; Year=$Year
        MonthTransitions=@($monthTransitions); MonthLengthChanges=@($monthTransitions | Where-Object MonthLengthChanged)
        YearTransition=if($hasYearTransition){$monthTransitions[-1]}else{$null}; HasYearTransition=$hasYearTransition
        LeapDay=if([datetime]::IsLeapYear($Year)){[datetime]::new($Year,2,29)}else{$null}; ISOWeekYearTransitions=$isoChanges.ToArray()
    }
}
