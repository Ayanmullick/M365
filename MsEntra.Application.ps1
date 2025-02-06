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