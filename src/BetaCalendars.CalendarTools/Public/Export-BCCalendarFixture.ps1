function Export-BCCalendarFixture {
    <#
    .SYNOPSIS
    Serializes calendar data as JSON, CSV, or Markdown.
    .DESCRIPTION
    Returns text by default. When Path is provided, writes UTF-8 without a BOM and returns the path.
    .PARAMETER InputObject
    Calendar grids, year-turn fixture items, or other structured values.
    .PARAMETER Format
    Json, Csv, or Markdown.
    .PARAMETER Path
    Optional destination path for UTF-8 output.
    .EXAMPLE
    New-BCYearTurnFixture -Year 2026 | Export-BCCalendarFixture -Format Json
    .INPUTS
    System.Object values from the pipeline.
    .OUTPUTS
    System.String serialized content or the written path.
    .NOTES
    JSON is indented; CSV column order follows the input properties.
    .LINK
    New-BCYearTurnFixture
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory,ValueFromPipeline)][object]$InputObject,
          [Parameter(Mandatory)][ValidateSet('Json','Csv','Markdown')][string]$Format,
          [string]$Path)
    begin { $items=[Collections.Generic.List[object]]::new() }
    process { foreach($value in $InputObject){ $items.Add($value) } }
    end {
        switch ($Format) {
            Json { $text=ConvertTo-Json -InputObject @($items) -Depth 12 }
            Csv {
                $rows=foreach($item in $items){
                    if($item.PSObject.Properties['Grid']){[pscustomobject][ordered]@{Year=$item.Year;Month=$item.Month;MonthName=$item.MonthName;DaysInMonth=$item.DaysInMonth;GridRows=$item.Grid.Rows}}
                    elseif($item.PSObject.Properties['Cells']){foreach($cell in $item.Cells){$cell}}
                    else{$item}
                }
                $text=(@($rows | ConvertTo-Csv -NoTypeInformation) -join "`n")
            }
            Markdown {
                $rows=foreach($item in $items){
                    if($item.PSObject.Properties['Grid']){[pscustomobject][ordered]@{Year=$item.Year;Month=$item.MonthName;Days=$item.DaysInMonth;Rows=$item.Grid.Rows}}
                    elseif($item.PSObject.Properties['Cells']){foreach($cell in $item.Cells){$cell}}
                    else{$item}
                }
                $rows=@($rows); if($rows.Count -eq 0){$text=''}else{
                    $columns=@($rows[0].PSObject.Properties.Name); $line='| '+($columns -join ' | ')+' |'; $divider='| '+(($columns | ForEach-Object {'---'}) -join ' | ')+' |'
                    $body=foreach($row in $rows){'| '+(($columns | ForEach-Object { $value=$row.$_; if($null -eq $value){''}else{([string]$value).Replace('|','\|').Replace("`n",' ')} }) -join ' | ')+' |'}
                    $text=(@($line,$divider)+@($body)) -join "`n"
                }
            }
        }
        if($Path){$full=[IO.Path]::GetFullPath($Path); [IO.File]::WriteAllText($full,$text,[Text.UTF8Encoding]::new($false)); return $full}
        return $text
    }
}
