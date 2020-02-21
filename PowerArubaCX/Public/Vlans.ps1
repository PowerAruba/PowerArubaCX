#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Add-ArubaCXVlans {

    <#
        .SYNOPSIS
        Add Aruba CX Vlan

        .DESCRIPTION
        Add Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Add-ArubaCXVlans -name Vlan 2 -id 2

        Add Vlan id 2 named Vlan 2

        .EXAMPLE
        Add-ArubaCXVlans -name Vlan 2 -id 2 -description "Add via PowerArubaCX" -voice

        Add Vlan with a description and enable voice

        .EXAMPLE
        Add-ArubaCXVlans -name Vlan 2 -id 2 -admin down -vsx_sync

        Add Vlan with a VSX Sync and admin down
    #>
    Param(
        [Parameter (Mandatory = $true)]
        [ValidateRange(1, 4096)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [ValidateSet('up', 'down')]
        [string]$admin,
        [Parameter (Mandatory = $false)]
        [switch]$voice,
        [Parameter (Mandatory = $false)]
        [switch]$vsx_sync,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/vlans"

        $_vlan = new-Object -TypeName PSObject

        $_vlan | add-member -name "id" -membertype NoteProperty -Value $id

        $_vlan | add-member -name "name" -membertype NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_vlan | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            $_vlan | add-member -name "admin" -membertype NoteProperty -Value $admin
        }

        if ( $PsBoundParameters.ContainsKey('voice') ) {
            if ($voice) {
                $_vlan | add-member -name "voice" -membertype NoteProperty -Value $true
            }
            else {
                $_vlan | add-member -name "voice" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vsx_sync') ) {
            if ($vsx_sync) {
                $_vlan | add-member -name "vsx_sync" -membertype NoteProperty -Value @("all_attributes_and_dependents")
            }
            else {
                $_vlan | add-member -name "vsx_sync" -membertype NoteProperty -Value ""
            }
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_vlan -connection $connection
        $response

        Get-ArubaCXVlans -id $id -connection $connection
    }

    End {
    }
}

function Get-ArubaCXVlans {

    <#
        .SYNOPSIS
        Get list of all Aruba CX Vlan

        .DESCRIPTION
        Get list of all Aruba CX Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlans

        Get list of all vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlans -id 23

        Get vlan with id 23

        .EXAMPLE
        Get-ArubaCXVlans -name MyVlan

        Get vlan named MyVlan
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "id")]
        [ValidateRange(1, 4096)]
        [int]$id,
        [Parameter (Mandatory = $false, ParameterSetName = "name")]
        [string]$name,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4)]
        [Int]$depth,
        [Parameter(Mandatory = $false)]
        [ValidateSet("configuration", "status", "statistics", "writable")]
        [String]$selector,
        [Parameter(Mandatory = $false)]
        [String[]]$attributes,
        [Parameter(Mandatory = $false)]
        [switch]$vsx_peer,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {


        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('depth') ) {
            $invokeParams.add( 'depth', $depth )
        }
        if ( $PsBoundParameters.ContainsKey('selector') ) {
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        #if filter by name always set depth to 2
        if ($PsBoundParameters.ContainsKey('name') -and ($depth -eq "")) {
            $invokeParams.add( 'depth', 2 )
        }

        $uri = "system/vlans"

        # you can directly filter by id
        if ( $PsBoundParameters.ContainsKey('id') ) {
            $uri += "/$id"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        #Add id parameter when use writable type selector
        if ( $PsBoundParameters.ContainsKey('selector') -and $selector -eq "writable" ) {
            $response | add-member -name "id" -membertype NoteProperty -Value $id
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "name" {
                #Need to make own filter for name (and use a depth >= 2)
                $response.psobject.Properties.Value | Where-Object { $_.name -eq $name }
            }
            default {
                $response
            }
        }
    }

    End {
    }
}

function Set-ArubaCXVlans {

    <#
        .SYNOPSIS
        Configure Aruba CX Vlan

        .DESCRIPTION
        Configure Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlans -id 44 | Set-ArubaCXVlans -name "My New Vlan Name" -description "My Description change by PowerArubaCX"

        Change the name and description of vlan id 44

        .EXAMPLE
        Get-ArubaCXVlans -id 44 | Set-ArubaCXVlans -voice -admin up

        Configure Vlan 44 with voice vlan and set admin to up

        .EXAMPLE
        Get-ArubaCXVlans -id 44 | Set-ArubaCXVlans -vsx_sync -voice -admin down

        Configure Vlan 44 with enable VSX sync and set admin to status

        .EXAMPLE
        $vlan = Get-ArubaCXVlans -id 44 -selector writable
        PS> $vlan.name = "My Vlan"
        PS> $vlan | Set-ArubaCXVlans -use_pipeline

        Configure Vlan 44 name using pipeline (can be only with selector equal writable)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [ValidateRange(1, 4096)]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        [ValidateScript( { Confirm-ArubaCXVlans $_ })]
        [psobject]$vlan,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [ValidateSet('up', 'down')]
        [string]$admin,
        [Parameter (Mandatory = $false)]
        [switch]$voice,
        [Parameter (Mandatory = $false)]
        [switch]$vsx_sync,
        [Parameter (Mandatory = $false)]
        [switch]$use_pipeline,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if ($vlan) {
            $id = $vlan.id
        }

        $uri = "system/vlans/${id}"

        if ($use_pipeline) {
            $_vlan = $vlan
        }
        else {
            $_vlan = Get-ArubaCXVlans -id $id -selector writable -connection $connection
        }

        #Remove id from vlan (can not be modified)
        $_vlan.psobject.Properties.remove("id")

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_vlan.name = $name
        }
        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_vlan.description = $description
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            $_vlan.admin = $admin
        }

        if ( $PsBoundParameters.ContainsKey('voice') ) {
            if ($voice) {
                $_vlan.voice = $true
            }
            else {
                $_vlan.voice = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vsx_sync') ) {
            if ($vsx_sync) {
                $_vlan.vsx_sync = @("all_attributes_and_dependents")
            }
            else {
                $_vlan.vsx_sync = $null
            }
        }

        if ($PSCmdlet.ShouldProcess($id, 'Configure Vlan Settings')) {
            $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_vlan -connection $connection
            $response
        }

        Get-ArubaCXVlans -id $id -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXVlans {

    <#
        .SYNOPSIS
        Remove a vlan on Aruba CX Switch

        .DESCRIPTION
        Remove a vlan on Aruba CX Switch

        .EXAMPLE
        $vlan = Get-ArubaCXVlans -name MyVlan
        PS C:\>$vlan | Remove-ArubaCXVlans

        Remove vlan named MyVlan

        .EXAMPLE
        Remove-ArubaCXVlans -id 23 -confirm:$false

        Remove Vlan with id 23 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        [ValidateScript( { Confirm-ArubaCXVlans $_ })]
        [psobject]$vlan,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if ($vlan) {
            $id = $vlan.id
        }

        $uri = "system/vlans/${id}"

        if ($PSCmdlet.ShouldProcess("Vlan", "Remove Vlan ${id}")) {
            Write-Progress -activity "Remove Vlan"
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Vlan" -completed
        }
    }

    End {
    }
}