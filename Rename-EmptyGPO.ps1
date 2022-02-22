$prefixEmpty = "EMPTY"
foreach ($GPO in (Get-GPO -All).DisplayName)
{
    [xml]$report = Get-GPOReport -Name $GPO -ReportType Xml
    if ($report.GPO.Computer.ExtensionData -eq $null -and $report.GPO.User.ExtensionData -eq $null)
    {
        Rename-GPO $GPO -TargetName "$prefixEmpty-$GPO" -WhatIf
    }
}
