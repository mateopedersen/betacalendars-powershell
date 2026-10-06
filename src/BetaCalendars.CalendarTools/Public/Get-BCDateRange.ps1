function Get-BCDateRange {
    <#
    .SYNOPSIS
    Emits consecutive date-only DateTime values for an inclusive range.
    .DESCRIPTION
    Time components are discarded. The start and end dates are both included.
    .PARAMETER DateFrom
    First civil date in the inclusive range.
    .PARAMETER DateTo
    Last civil date in the inclusive range; must be on or after DateFrom.
    .EXAMPLE
    Get-BCDateRange -DateFrom '2024-02-28' -DateTo '2024-03-01'
    .INPUTS
    None.
    .OUTPUTS
    System.DateTime values with DateTimeKind Unspecified.
    .NOTES
    Time components and timezone kinds are ignored.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][datetime]$DateFrom,[Parameter(Mandatory)][datetime]$DateTo)
    $start=[datetime]::SpecifyKind($DateFrom.Date,[DateTimeKind]::Unspecified)
    $end=[datetime]::SpecifyKind($DateTo.Date,[DateTimeKind]::Unspecified)
    if ($end -lt $start) { throw 'DateTo must be on or after DateFrom.' }
    for ($date=$start; $date -le $end;) {
        [datetime]::SpecifyKind($date,[DateTimeKind]::Unspecified)
        if ($date -eq $end) { break }
        $date=$date.AddDays(1)
    }
}
