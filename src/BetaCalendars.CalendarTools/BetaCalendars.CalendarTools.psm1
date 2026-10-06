$privatePath = Join-Path $PSScriptRoot 'Private'
foreach ($script in Get-ChildItem -LiteralPath $privatePath -Filter '*.ps1' -File | Sort-Object Name) {
    . $script.FullName
}
$publicPath = Join-Path $PSScriptRoot 'Public'
foreach ($script in Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File | Sort-Object Name) {
    . $script.FullName
}
Export-ModuleMember -Function @(
    'New-BCMonthGrid','New-BCYearGrid','Get-BCDateRange','Get-BCRecurrence',
    'Get-BCBoundaryReport','New-BCYearTurnFixture','Export-BCCalendarFixture',
    'Test-BCCalendarInvariant'
)
