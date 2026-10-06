function Get-BCRecurrence {
    <#
    .SYNOPSIS
    Expands a civil-date recurrence within explicit bounds.
    .DESCRIPTION
    This bounded helper is not an RFC 5545 implementation. From and To are inclusive; MaxOccurrences is required and expansion errors rather than silently truncating.
    .PARAMETER Pattern
    Recurrence shape to expand.
    .PARAMETER From
    Inclusive first eligible civil date and recurrence anchor.
    .PARAMETER To
    Inclusive final civil date.
    .PARAMETER MaxOccurrences
    Positive hard limit; exceeding it raises an error.
    .PARAMETER Interval
    Positive day, week, or month interval for interval-based patterns.
    .PARAMETER Day
    Requested day of month for MonthlyDay or Annual.
    .PARAMETER Month
    Month number for Annual.
    .PARAMETER Ordinal
    Weekday ordinal from 1 through 5 for NthWeekday.
    .PARAMETER Weekday
    One or more weekday names for weekly and weekday-based rules.
    .PARAMETER InvalidDayPolicy
    Behavior when a monthly or annual requested day is unavailable.
    .EXAMPLE
    Get-BCRecurrence -Pattern Annual -From '2024-02-29' -To '2028-12-31' -MaxOccurrences 10 -Month 2 -Day 29 -InvalidDayPolicy Clamp
    .INPUTS
    None.
    .OUTPUTS
    System.DateTime values with DateTimeKind Unspecified.
    .NOTES
    Every expansion has explicit date bounds and a positive occurrence cap. This is not RFC 5545.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('Daily','Weekly','MonthlyDay','NthWeekday','LastWeekday','Annual')][string]$Pattern,
        [Parameter(Mandatory)][datetime]$From,
        [Parameter(Mandatory)][datetime]$To,
        [Parameter(Mandatory)][ValidateRange(1,1000000)][int]$MaxOccurrences,
        [ValidateRange(1,1000000)][int]$Interval=1,
        [ValidateRange(1,31)][int]$Day,
        [ValidateRange(1,12)][int]$Month,
        [ValidateRange(1,5)][int]$Ordinal,
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')][string[]]$Weekday,
        [ValidateSet('Skip','Clamp','Error')][string]$InvalidDayPolicy='Skip'
    )
    $start=[datetime]::SpecifyKind($From.Date,[DateTimeKind]::Unspecified)
    $end=[datetime]::SpecifyKind($To.Date,[DateTimeKind]::Unspecified)
    if ($end -lt $start) { throw 'To must be on or after From.' }
    if ($Pattern -in @('MonthlyDay','Annual') -and -not $PSBoundParameters.ContainsKey('Day')) { throw "-Day is required for $Pattern." }
    if ($Pattern -eq 'Annual' -and -not $PSBoundParameters.ContainsKey('Month')) { throw '-Month is required for Annual.' }
    if ($Pattern -in @('NthWeekday','LastWeekday') -and -not $PSBoundParameters.ContainsKey('Weekday')) { throw "-Weekday is required for $Pattern." }
    if ($Pattern -eq 'NthWeekday' -and -not $PSBoundParameters.ContainsKey('Ordinal')) { throw '-Ordinal is required for NthWeekday.' }
    $dates = [Collections.Generic.List[datetime]]::new()
    $firstMonth = [datetime]::new($start.Year,$start.Month,1)
    for ($cursor=$start; $cursor -le $end;) {
        $candidate=$false
        switch ($Pattern) {
            Daily { $candidate=(([int]($cursor-$start).TotalDays % $Interval) -eq 0) }
            Weekly {
                $weekStart = $start.AddDays(-(((int)$start.DayOfWeek - (ConvertTo-BCWeekdayNumber 'Monday') + 7) % 7))
                $cursorWeek = $cursor.AddDays(-(((int)$cursor.DayOfWeek - (ConvertTo-BCWeekdayNumber 'Monday') + 7) % 7))
                $weeks=[int](($cursorWeek-$weekStart).TotalDays/7)
                $candidate=($weeks % $Interval -eq 0) -and $cursor.DayOfWeek -eq $start.DayOfWeek
                if ($PSBoundParameters.ContainsKey('Weekday')) { $candidate=($weeks % $Interval -eq 0) -and ([string]$cursor.DayOfWeek -in $Weekday) }
            }
            MonthlyDay {
                $months=(($cursor.Year-$firstMonth.Year)*12 + $cursor.Month-$firstMonth.Month)
                if ($months % $Interval -eq 0) { $actual=Get-BCDayOfMonth -Year $cursor.Year -Month $cursor.Month -Day $Day -Policy $InvalidDayPolicy; $candidate=$actual -gt 0 -and $cursor.Day -eq $actual }
            }
            Annual {
                if ($cursor.Month -eq $Month) { $actual=Get-BCDayOfMonth -Year $cursor.Year -Month $Month -Day $Day -Policy $InvalidDayPolicy; $candidate=$actual -gt 0 -and $cursor.Day -eq $actual }
            }
            NthWeekday {
                if ([string]$cursor.DayOfWeek -in $Weekday) { $candidate=[int][math]::Floor(($cursor.Day-1)/7)+1 -eq $Ordinal }
            }
            LastWeekday {
                if ([string]$cursor.DayOfWeek -in $Weekday) { $candidate=($cursor.Day + 7) -gt [datetime]::DaysInMonth($cursor.Year,$cursor.Month) }
            }
        }
        if ($candidate) {
            if ($dates.Count -ge $MaxOccurrences) { throw "The recurrence exceeds MaxOccurrences ($MaxOccurrences)." }
            $dates.Add($cursor)
        }
        if ($cursor -eq $end) { break }
        $cursor=$cursor.AddDays(1)
    }
    $dates.ToArray()
}
