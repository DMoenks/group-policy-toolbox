#region:Computer
if (Test-Path "$env:ProgramData\Microsoft\Group Policy\History")
{
    Get-ChildItem "$env:ProgramData\Microsoft\Group Policy\History" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "$env:ProgramData\GroupPolicy")
{
    Get-ChildItem "$env:ProgramData\GroupPolicy" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
if ($null -ne ($root = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Policies', $true)))
{
    foreach ($key in $root.GetSubKeyNames())
    {
        try
        {
            $root.DeleteSubKeyTree($key)
        }
        catch [System.Exception]
        {

        }
    }
}
if (Test-Path "$env:SystemRoot\System32\GroupPolicy")
{
    Get-ChildItem "$env:SystemRoot\System32\GroupPolicy" | Remove-Item  -Recurse -Force -ErrorAction SilentlyContinue
}
#endregion
#region:User
$profiles = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList')
foreach ($profileSID in $profiles.GetSubKeyNames() -match '^S-1-5-21(-\d+){4}$')
{
    $profilePath = $profiles.OpenSubKey($profileSID).GetValue('ProfileImagePath')
    if (Test-Path "$profilePath\AppData\Local\Microsoft\Group Policy\History")
    {
        Get-ChildItem "$profilePath\AppData\Local\Microsoft\Group Policy\History" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$profilePath\AppData\Local\GroupPolicy")
    {
        Get-ChildItem "$profilePath\AppData\Local\GroupPolicy" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    if ($null -ne ($root = [Microsoft.Win32.Registry]::Users.OpenSubKey("$profileSID\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies", $true)))
    {
        foreach ($key in $root.GetSubKeyNames())
        {
            try
            {
                $root.DeleteSubKeyTree($key)
            }
            catch [System.Exception]
            {

            }
        }
    }
}
if (Test-Path "$env:SystemRoot\System32\GroupPolicyUsers")
{
    Get-ChildItem "$env:SystemRoot\System32\GroupPolicyUsers" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
#endregion
Start-Process 'GPupdate' -ArgumentList '/Force' -WindowStyle Hidden -Wait
