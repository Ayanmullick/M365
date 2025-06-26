# Install the MSGraph Intune PowerShell module if not already installed
Install-Module -Name Microsoft.Graph.Intune

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Get the list of Windows devices
$devices = Get-IntuneManagedDevice -Filter "operatingSystem eq 'Windows'"

#Alias disn't work
Get-IntuneManagedDevice|select -First 1
#Get-DeviceManagement_ManagedDevices: Not authenticated.  Please use the "Connect-MSGraph" command to authenticate.
Connect-MSGraph  
#Connect-MSGraph: Could not load type 'System.Security.Cryptography.SHA256Cng' from assembly 'System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.

Get-MgDeviceManagementManagedDevice|select -First 1|fl  #Worked
Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'"|select -First 1|fl #Worked
(Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'").count           #1000
# Display the list of devices
$devices | Format-Table DisplayName, DeviceId, OperatingSystem, OperatingSystemVersion, ManagementState, OwnerType


<#
MDM user scope to some
select group


device restriction profile in device config

#region 3 ways to sync settings in Win10
Enterprise state roaming
Intune device configuration: device restriction profiles, administrative template profiles, CSP policy profiles
Sync settings using Win10 'Settings Sync'
#endregion

#>