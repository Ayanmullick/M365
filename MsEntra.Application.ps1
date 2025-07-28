#region Get applications with expiring secrets in the next month
Connect-Entra -Scopes 'Application.Read.All'
(Get-EntraApplication).Where({ $_.PasswordCredentials.EndDate -lt (Get-Date).AddMonths(1) }) |
    ForEach-Object {$owner = Get-EntraApplicationOwner -ApplicationId $_.Id
        [PSCustomObject]@{
            Name = $_.DisplayName
            Id = $_.Id
            ExpiryDates = (($_.PasswordCredentials).Where({ $_.EndDate }) | ForEach-Object { $_.EndDate.ToString("MM.dd.yy") }) -join ',' ?? 'N/A'
            Owner = if ($owner) { $owner.displayName -join ',' } else { "N/A" }
        }
    } | Format-Table -Property @{n='Name'; e={$_.Name}; Width=60},@{n='Id'; e={$_.Id}; Width=36},@{n='ExpiryDates'; e={$_.ExpiryDates}; Width=40},@{n='Owner'; e={$_.Owner}; Width=40} -Wrap
#endregion


#region Assign an app role to a service principal 
Connect-Entra -Scopes 'AppRoleAssignment.ReadWrite.All'
#Get-EntraServicePrincipal -ServicePrincipalId <ClientId>  #Fails with Client id.| does not exist or one of its queried reference-property objects are not present.
$clientServicePrincipal = Get-EntraServicePrincipal -Filter "displayName eq 'AppIntegrations'"
$resourceServicePrincipal = Get-EntraServicePrincipal -Filter "displayName eq 'Microsoft Graph'"  #There are 2 resources. One for existing tenant and another for multi-tenant
$appRole = $resourceServicePrincipal.AppRoles | Where-Object { $_.Value -eq "Files.Read.All" }

#New-EntraServicePrincipalAppRoleAssignment -ObjectId $clientServicePrincipal.Id -PrincipalId $clientServicePrincipal.Id -Id $appRole.Id -ResourceId $resourceServicePrincipal.Id

New-EntraServicePrincipalAppRoleAssignment -ObjectId $clientServicePrincipal.Id -PrincipalId $clientServicePrincipal.Id -Id $appRole.Id `
    -ResourceId ($resourceServicePrincipal|? SignInAudience -Like '*My*').Id -Verbose   #Error: Permission being assigned was not found on application 
#endregion    


Get-EntraServicePrincipal -Filter "displayName eq '<UAMI>'"|FL
Get-EntraServicePrincipal -ServicePrincipalId <UAMI Principal Id>
<#managed identities—whether system‑ or user‑assigned—are designed exclusively for outbound authentication
 it isn’t designed to support the interactive sign‐in flows required for inbound authentication

There’s no Microsoft‑supported way to attach an application object to the existing service principal that backs your user‑assigned identity. 
If you need an actual app registration for OAuth or for custom usage, you must create a separate application object and then create a service principal for it.
#>
# The 'create new app registration' option in the 'Authentication' blade for a function creates a new Enterprise application object and a new service principal object.
Get-EntraApplication -Filter "displayName eq 'Test-func-pwsh-d-c-01'" 
Get-EntraServicePrincipal -Filter "displayName eq 'Test-func-pwsh-d-c-01'"


#region  Create an Entra App, associate a service principal and store it's credential in a vault.
Connect-Entra -Scopes 'Application.ReadWrite.All','Directory.Read.All'

$app = New-EntraApplication -DisplayName "<>"
#$app = Get-EntraApplication -Filter "displayName eq '<>'"

$sp = New-EntraServicePrincipal -AppId $app.AppId
New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName Reader
$secret = New-EntraServicePrincipalPasswordCredential -ServicePrincipalId $sp.Id -DisplayName "<>" -StartDate (Get-Date) -EndDate (Get-Date).AddYears(2)
#$secretText = $secret.SecretText  #This stores the system generated password

$secureSecret = ConvertTo-SecureString -String $secret.SecretText -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName 'kv-cubic-d-c-01' -Name $secret.DisplayName -SecretValue $secureSecret
#endregion