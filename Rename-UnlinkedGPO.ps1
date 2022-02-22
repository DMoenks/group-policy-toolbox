$GPOs = @{}
foreach ($GPOGUID in (Get-GPO -All).Id)
{
    $GPOs.Add($GPOGUID.ToString().ToUpper(), 0)
}
foreach ($GPODN in (Get-ADDomain).LinkedGroupPolicyObjects)
{
    $GPOID = [regex]::Match($GPODN, '{(\w+(?:-\w+)+)}').Groups[1].Value
    $GPOs[$GPOID]++
}
foreach ($OU in Get-ADOrganizationalUnit -Filter 'LinkedGroupPolicyObjects -like "*"')
{
    foreach ($GPODN in $OU.LinkedGroupPolicyObjects)
    {
        $GPOID = [regex]::Match($GPODN, '{(\w+(?:-\w+)+)}').Groups[1].Value
        $GPOs[$GPOID]++
    }
}
foreach ($GPOID in $GPOs.Keys)
{
    if ($GPOs[$GPOID] -eq 0)
    {
        $GPOName = (Get-GPO -Guid $GPOID).DisplayName
        Rename-GPO -Guid $GPOID -TargetName "UNLINKED-$GPOName"
    }
}
