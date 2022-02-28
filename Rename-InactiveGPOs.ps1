$GPOs = Get-GPO -All

# empty GPOs
foreach ($GPO in $GPOs.DisplayName)
{
    [xml]$report = Get-GPOReport -Name $GPO -ReportType Xml
    if ($null -eq $report.GPO.Computer.ExtensionData -and $null -eq $report.GPO.User.ExtensionData)
    {
        Rename-GPO $GPO -TargetName "EMPTY-$GPO" -WhatIf
    }
}

# unlinked GPOs
$GPOlinks = @{}
foreach ($GPOGUID in (Get-GPO -All).Id)
{
    $GPOlinks.Add($GPOGUID.ToString().ToUpper(), 0)
}
foreach ($GPODN in (Get-ADDomain).LinkedGroupPolicyObjects)
{
    $GPOID = [regex]::Match($GPODN, '{(\w+(?:-\w+)+)}').Groups[1].Value
    $GPOlinks[$GPOID]++
}
foreach ($OU in Get-ADOrganizationalUnit -Filter 'LinkedGroupPolicyObjects -like "*"')
{
    foreach ($GPODN in $OU.LinkedGroupPolicyObjects)
    {
        $GPOID = [regex]::Match($GPODN, '{(\w+(?:-\w+)+)}').Groups[1].Value
        $GPOlinks[$GPOID]++
    }
}
foreach ($GPOID in $GPOlinks.Keys)
{
    if ($GPOlinks[$GPOID] -eq 0)
    {
        $GPOName = (Get-GPO -Guid $GPOID).DisplayName
        Rename-GPO -Guid $GPOID -TargetName "UNLINKED-$GPOName"
    }
}
