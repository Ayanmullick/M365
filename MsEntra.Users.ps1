Connect-Entra -Scopes 'User.ReadWrite.All', 'Directory.AccessAsUser.All' -Verbose

Get-EntraUser

#region Disable user and verify
Set-EntraUser -UserId 17ecbbb8-6df0-4c76-85d9-1364d2e5658c -AccountEnabled $false -Verbose
Get-EntraUser -UserId 17ecbbb8-6df0-4c76-85d9-1364d2e5658c|Select-Object accountEnabled
#endregion


#region reset password
Connect-Entra -Scopes 'Directory.AccessAsUser.All'
$securePassword = ConvertTo-SecureString '<>' -AsPlainText -Force
Set-EntraUserPassword -ObjectId '05068d80-2789-41fd-92b0-fd5eb32ec8fc' -Password $securePassword -Verbose
#endregion