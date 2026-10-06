$modulePath = Join-Path $PSScriptRoot '../src/BetaCalendars.CalendarTools/BetaCalendars.CalendarTools.psd1'
Import-Module $modulePath -Force

Describe 'BetaCalendars.CalendarTools manifest and exports' {
    It 'has a valid manifest and explicit public functions' {
        { Test-ModuleManifest $modulePath -ErrorAction Stop } | Should -Not -Throw
        $commands = @(Get-Command -Module BetaCalendars.CalendarTools -CommandType Function)
        $commands.Count | Should -Be 8
        (Get-Command -Module BetaCalendars.CalendarTools -Name '*') | Should -Not -BeNullOrEmpty
    }
}

Describe 'New-BCMonthGrid' {
    It 'uses every requested weekday as the first column' {
        foreach ($weekday in @('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')) {
            (New-BCMonthGrid -Year 2027 -Month 1 -WeekStart $weekday).Cells[0].Weekday | Should -Be $weekday
        }
    }

    It 'always emits 42 cells for FixedSixWeeks' -ForEach @(
        @{Year=2027;Month=1}, @{Year=2024;Month=2}, @{Year=2026;Month=11}, @{Year=2000;Month=2}
    ) {
        (New-BCMonthGrid -Year $Year -Month $Month).Cells.Count | Should -Be 42
    }

    It 'emits unique in-month dates and consecutive adjacent overflow' {
        $grid = New-BCMonthGrid -Year 2027 -Month 1 -WeekStart Sunday
        $dates = @($grid.Cells | Where-Object InMonth | ForEach-Object Date)
        $dates.Count | Should -Be 31
        @($dates | Sort-Object -Unique).Count | Should -Be 31
        for ($i=1; $i -lt $grid.Cells.Count; $i++) {
            $grid.Cells[$i].Date | Should -Be $grid.Cells[$i-1].Date.AddDays(1)
        }
    }

    It 'supports compact layout and blank overflow' {
        $grid = New-BCMonthGrid -Year 2021 -Month 2 -Layout Compact -Overflow Blank
        $grid.Rows | Should -Be 4
        $grid.Cells.Count | Should -Be 28
        $overflow = New-BCMonthGrid -Year 2021 -Month 8 -Layout Compact -Overflow Blank
        @($overflow.Cells | Where-Object { -not $_.InMonth -and $null -eq $_.Date }).Count | Should -BeGreaterThan 0
    }

    It 'preserves geometry while blanking overflow dates' {
        $grid = New-BCMonthGrid -Year 2027 -Month 1 -Overflow Blank
        $grid.Cells.Count | Should -Be 42
        @($grid.Cells | Where-Object { -not $_.InMonth -and $null -eq $_.Date }).Count | Should -BeGreaterThan 0
    }

    It 'supports the first and last representable civil years' {
        (New-BCMonthGrid -Year 1 -Month 1 -Overflow Adjacent).Cells.Count | Should -Be 42
        (New-BCMonthGrid -Year 9999 -Month 12 -Overflow Adjacent).Cells.Count | Should -Be 42
    }

    It 'does not depend on input timezone kind' {
        $local = [datetime]::SpecifyKind([datetime]'2027-01-01',[DateTimeKind]::Local)
        $grid = New-BCMonthGrid -Year $local.Year -Month $local.Month
        $grid.Cells[0].Date.Kind | Should -Be ([DateTimeKind]::Unspecified)
    }
}

Describe 'date range and recurrence' {
    It 'follows Gregorian leap-year rules' {
        ([datetime]::IsLeapYear(1900)) | Should -BeFalse
        ([datetime]::IsLeapYear(2000)) | Should -BeTrue
        ([datetime]::IsLeapYear(2024)) | Should -BeTrue
        ([datetime]::IsLeapYear(2027)) | Should -BeFalse
    }

    It 'includes both endpoints across leap day' {
        $dates = @(Get-BCDateRange -DateFrom '2024-02-28T23:00:00Z' -DateTo '2024-03-01T12:00:00Z')
        $dates.Count | Should -Be 3
        $dates[1].ToString('yyyy-MM-dd') | Should -Be '2024-02-29'
        $dates[0].Kind | Should -Be ([DateTimeKind]::Unspecified)
    }

    It 'clamps an annual February 29 rule within explicit bounds' {
        $dates = @(Get-BCRecurrence -Pattern Annual -From '2024-01-01' -To '2028-12-31' -MaxOccurrences 5 -Month 2 -Day 29 -InvalidDayPolicy Clamp)
        @($dates | ForEach-Object { $_.ToString('yyyy-MM-dd') }) | Should -Be @('2024-02-29','2025-02-28','2026-02-28','2027-02-28','2028-02-29')
    }

    It 'fails instead of truncating beyond the explicit limit' {
        { Get-BCRecurrence -Pattern Daily -From '2024-01-01' -To '2024-01-10' -MaxOccurrences 2 -ErrorAction Stop } | Should -Throw '*MaxOccurrences*'
    }

    It 'supports skip, clamp, and error for invalid monthly days' {
        $skip = @(Get-BCRecurrence -Pattern MonthlyDay -From '2024-01-01' -To '2024-03-31' -MaxOccurrences 5 -Day 31 -InvalidDayPolicy Skip)
        @($skip | ForEach-Object { $_.ToString('yyyy-MM-dd') }) | Should -Be @('2024-01-31','2024-03-31')
        $clamp = @(Get-BCRecurrence -Pattern MonthlyDay -From '2024-01-01' -To '2024-03-31' -MaxOccurrences 5 -Day 31 -InvalidDayPolicy Clamp)
        @($clamp | ForEach-Object { $_.ToString('yyyy-MM-dd') }) | Should -Be @('2024-01-31','2024-02-29','2024-03-31')
        { Get-BCRecurrence -Pattern MonthlyDay -From '2024-02-01' -To '2024-02-29' -MaxOccurrences 5 -Day 31 -InvalidDayPolicy Error -ErrorAction Stop } | Should -Throw '*does not exist*'
    }

    It 'supports nth and last weekday patterns' {
        $nth = @(Get-BCRecurrence -Pattern NthWeekday -From '2024-01-01' -To '2024-02-29' -MaxOccurrences 4 -Ordinal 2 -Weekday Tuesday)
        $nth.Count | Should -Be 2
        $last = @(Get-BCRecurrence -Pattern LastWeekday -From '2024-01-01' -To '2024-02-29' -MaxOccurrences 4 -Weekday Friday)
        $last.Count | Should -Be 2
    }

    It 'selects multiple weekly weekdays' {
        $dates = @(Get-BCRecurrence -Pattern Weekly -From '2024-01-01' -To '2024-01-07' -MaxOccurrences 5 -Weekday Monday,Wednesday,Friday)
        $dates.Count | Should -Be 3
    }
}

Describe 'boundaries and year-turn fixtures' {
    It 'returns 12 months and records February 29 in a leap year' {
        (New-BCYearGrid -Year 2028).Months.Count | Should -Be 12
        (Get-BCBoundaryReport -Year 2028).LeapDay.ToString('yyyy-MM-dd') | Should -Be '2028-02-29'
    }

    It 'covers the year turn and leap-year variation' {
        (New-BCYearTurnFixture -Year 2026).DaysInMonth | Should -Be @(30,31,31,28)
        (New-BCYearTurnFixture -Year 2027).DaysInMonth | Should -Be @(30,31,31,29)
        ([datetime]'2026-12-31').AddDays(1).ToString('yyyy-MM-dd') | Should -Be '2027-01-01'
    }
}

Describe 'exports and invariant results' {
    It 'serializes fixture data as JSON, CSV, and Markdown' {
        $fixture = New-BCYearTurnFixture -Year 2026
        (Export-BCCalendarFixture -InputObject $fixture -Format Json) | Should -Match 'February'
        (Export-BCCalendarFixture -InputObject $fixture -Format Csv) | Should -Match 'MonthName'
        (Export-BCCalendarFixture -InputObject $fixture -Format Markdown) | Should -Match '\| Year \| Month \| Days \| Rows \|'
    }

    It 'reports all requested invariants as passing' {
        $results = @(Test-BCCalendarInvariant -Year 2027 -Month 1)
        $results.Count | Should -Be 5
        @($results | Where-Object { -not $_.Passed }).Count | Should -Be 0
    }

    It 'writes UTF-8 fixture content when a path is supplied' {
        $path = Join-Path $TestDrive 'fixture.json'
        $result = New-BCYearTurnFixture -Year 2026 | Export-BCCalendarFixture -Format Json -Path $path
        Test-Path $path | Should -BeTrue
        $result | Should -Be $path
        Get-Content $path -Raw | Should -Match 'February'
    }
}
