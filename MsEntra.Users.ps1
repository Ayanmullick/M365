Connect-Entra -Scopes 'User.ReadWrite.All', 'Directory.AccessAsUser.All' -Verbose

Get-EntraUser

#region Disable user and verify
Set-EntraUser -UserId 17ecbbb8-6df0-4c76-85d9-1364d2e5658c -AccountEnabled $false -Verbose
Get-EntraUser -UserId 17ecbbb8-6df0-4c76-85d9-1364d2e5658c|Select-Object accountEnabled
#endregion