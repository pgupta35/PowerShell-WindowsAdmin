﻿# Script to locate DC(s) currently holding the FSMO roles and move them to a new DC
#
# Requires the Active Directory component of RSAT to be installed.
#

# Import the ActiveDirectory module
Import-Module -Name ActiveDirectory

# Where are we moving the roles to?
$newDC = ''

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

# Get all the domain controllers
$domainControllers = Get-ADDomainController -Filter *

# Find all the FSMO roles, theoretically they should all be on the same server but you never know!
$schemaMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'SchemaMaster'}).Name
$ridMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'RIDMaster'}).Name
$infrastructureMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'InfrastructureMaster'}).Name
$domainNamingMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'DomainNamingMaster'}).Name
$pdcEmulator = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'PDCEmulator'}).Name

# Move all the FSMO roles to the new server
Move-ADDirectoryServerOperationMasterRole -Server $schemaMaster -Identity $newDC -OperationMasterRole SchemaMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $ridMaster -Identity $newDC -OperationMasterRole RIDMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $infrastructureMaster -Identity $newDC -OperationMasterRole InfrastructureMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $domainNamingMaster -Identity $newDC -OperationMasterRole DomainNamingMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $pdcEmulator -Identity $newDC -OperationMasterRole PDCEmulator -Credential $adCredentials -Confirm:$false