function Get-BCMonthBounds {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateRange(1,9999)][int]$Year,
          [Parameter(Mandatory)][ValidateRange(1,12)][int]$Month)
    $start = [datetime]::new($Year,$Month,1)
    $end = [datetime]::new($Year,$Month,[datetime]::DaysInMonth($Year,$Month))
    [pscustomobject]@{ Start=$start; End=$end; Days=[datetime]::DaysInMonth($Year,$Month) }
}

function ConvertTo-BCWeekdayNumber {
    param([Parameter(Mandatory)][string]$Weekday)
    $map = @{ Sunday=0; Monday=1; Tuesday=2; Wednesday=3; Thursday=4; Friday=5; Saturday=6 }
    return [int]$map[$Weekday]
}

function Get-BCGridCells {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$Year,
        [Parameter(Mandatory)][int]$Month,
        [Parameter(Mandatory)][ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')][string]$WeekStart,
        [Parameter(Mandatory)][ValidateSet('FixedSixWeeks','Compact')][string]$Layout,
        [Parameter(Mandatory)][ValidateSet('Adjacent','Blank')][string]$Overflow,
        [datetime[]]$SpecialDate = @()
    )
    $bounds = Get-BCMonthBounds -Year $Year -Month $Month
    $weekStartNumber=ConvertTo-BCWeekdayNumber $WeekStart
    $firstOffset = (([int]$bounds.Start.DayOfWeek - $weekStartNumber) + 7) % 7
    $monthFirstOrdinal=[int](($bounds.Start-[datetime]::MinValue).TotalDays)
    $monthLastOrdinal=[int](($bounds.End-[datetime]::MinValue).TotalDays)
    $maxOrdinal=[int](([datetime]::MaxValue.Date-[datetime]::MinValue).TotalDays)
    $rows = if ($Layout -eq 'FixedSixWeeks') { 6 } else { [int][math]::Ceiling(($firstOffset + $bounds.Days) / 7) }
    for ($index=0; $index -lt ($rows * 7); $index++) {
        $ordinal=$monthFirstOrdinal+$index-$firstOffset
        $isRepresentable=$ordinal -ge 0 -and $ordinal -le $maxOrdinal
        $date=if($isRepresentable){$bounds.Start.AddDays($index-$firstOffset)}else{$null}
        $inMonth = $ordinal -ge $monthFirstOrdinal -and $ordinal -le $monthLastOrdinal
        $hasDate = ($inMonth -or $Overflow -eq 'Adjacent') -and $isRepresentable
        $weekday=[DayOfWeek](($weekStartNumber+$index%7)%7)
        $special = $false
        foreach ($item in $SpecialDate) { if ($item.Date -eq $date.Date) { $special = $true; break } }
        $weekYear = 0; $week = 0
        if ($hasDate) { $iso = [Globalization.ISOWeek]::GetYear($date); $weekYear = $iso; $week = [Globalization.ISOWeek]::GetWeekOfYear($date) }
        [pscustomobject][ordered]@{
            Date = if ($hasDate) { $date } else { $null }
            Year = if ($hasDate) { $date.Year } else { $null }
            Month = if ($hasDate) { $date.Month } else { $null }
            Day = if ($hasDate) { $date.Day } else { $null }
            Weekday = [string]$weekday
            Row = [int][math]::Floor($index / 7)
            Column = $index % 7
            InMonth = $inMonth
            IsWeekend = $weekday -in @([DayOfWeek]::Saturday,[DayOfWeek]::Sunday)
            IsMonthStart = $hasDate -and $inMonth -and $date.Day -eq 1
            IsMonthEnd = $hasDate -and $inMonth -and $date.Day -eq $bounds.Days
            IsYearStart = $hasDate -and $date.Month -eq 1 -and $date.Day -eq 1
            IsYearEnd = $hasDate -and $date.Month -eq 12 -and $date.Day -eq 31
            ISOWeek = if ($hasDate) { $week } else { $null }
            ISOWeekYear = if ($hasDate) { $weekYear } else { $null }
            IsSpecialDate = $hasDate -and $special
        }
    }
}

function Get-BCDayOfMonth {
    param([int]$Year,[int]$Month,[int]$Day,[ValidateSet('Skip','Clamp','Error')][string]$Policy)
    $last = [datetime]::DaysInMonth($Year,$Month)
    if ($Day -le $last) { return $Day }
    switch ($Policy) {
        Skip { return 0 }
        Clamp { return $last }
        Error { throw "Day $Day does not exist in $Year-$('{0:d2}' -f $Month)." }
    }
}
