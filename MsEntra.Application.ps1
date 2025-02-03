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
