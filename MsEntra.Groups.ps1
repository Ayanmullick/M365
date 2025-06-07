Connect-Entra -Scopes 'User.ReadWrite.All', 'Directory.AccessAsUser.All' -Verbose
New-EntraGroup -DisplayName '<DisplayName>' -MailEnabled $false -SecurityEnabled $true -MailNickname "<>" -Description "<>" -Verbose
$Group = Get-EntraGroup -Filter "mailNickname eq 'DisplayName'"

$emails = @('Ayan.Mullick@<>', '<>@<>','<>@<>','<>@<>','<>@<>')
     foreach ($email in $emails) {
         $user = Get-EntraUser -Filter "mail eq '$email'"
         Add-EntraGroupMember -GroupId $group.Id -RefObjectId $user.Id
     }

Get-EntraGroup -Filter "displayname eq '<>'" #Works too for Type : Security     


Add-EntraGroupMember -GroupId $group.Id -RefObjectId $UAMI.PrincipalId #Add a user assigned MSI in an Entra group