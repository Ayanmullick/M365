#region Check which user or group a specific role is assigned to
Connect-Entra -Scopes 'RoleManagement.Read.Directory', 'Directory.Read.All'
$roleDefinition = Get-EntraDirectoryRoleDefinition|Where-Object { $_.DisplayName -eq "Service Support Administrator" }
Get-EntraDirectoryRoleAssignment -Filter "RoleDefinitionId eq '$($roleDefinition.Id)'"
Get-EntraUser -UserId $PrincipalId
#endregion