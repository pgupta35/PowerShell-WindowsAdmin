﻿# Script to get a list of all VMs in one or more datastores
#
# Updated for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Where to save the list to
$outputfile = 'C:\Temp\VMsByDatastore.csv'

# Which datastores to get VMs for?
# For example, using a wildcard to get all datastores with similar names
$datastores = Get-Datastore | Where-Object {$_.Name -like '*Tier*'}

# Initialise the output object
$vmsTable = @()

# Build the output object from the VM list
foreach ($datastore in $datastores) {
    $vms = Get-VM -Datastore $datastore
    foreach ($vm in $vms) {
        $tableRow = New-Object System.Object
        $tableRow | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
        $tableRow | Add-Member -MemberType NoteProperty -Name 'PowerState' -Value $vm.PowerState
        $tableRow | Add-Member -MemberType NoteProperty -Name 'Datastore' -Value $datastore
        $tableRow | Add-Member -MemberType NoteProperty -Name 'Notes' -Value ($vm.Notes -replace "`n"," ")
        $vmsTable += $tableRow
    }
}

# Output to a CSV file
$vmsTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false
