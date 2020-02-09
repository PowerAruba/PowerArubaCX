#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Add-ArubaCXVlan {

    <#
        .SYNOPSIS
        Add Aruba CX Vlan

        .DESCRIPTION
        Add Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Add-ArubaCXVlan -name Vlan 2 -id 2

        Add Vlan id 2 named Vlan 2

        .EXAMPLE
        Add-ArubaCXVlan -name Vlan 2 -id 2 -description "Add via PowerArubaCX" -voice

        Add Vlan with a description and enable voice

        .EXAMPLE
        Add-ArubaCXVlan -name Vlan 2 -id 2 -admin down -vsx_sync

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
        [PSObject]$connection = $DefaultArubaSWConnection
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

        Get-ArubaCXVlan -id $id -connection $connection
    }

    End {
    }
}

function Get-ArubaCXVlan {

    <#
        .SYNOPSIS
        Get list of all Aruba CX Vlan

        .DESCRIPTION
        Get list of all Aruba CX Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlan

        Get list of all vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlan -id 23

        Get vlan with id 23

        .EXAMPLE
        Get-ArubaCXVlan -name MyVlan

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
        [PSObject]$connection = $DefaultArubaSWConnection
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

function Set-ArubaCXVlan {

    <#
        .SYNOPSIS
        Configure Aruba CX Vlan

        .DESCRIPTION
        Configure Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlan -id 44 | Set-ArubaCXVlan -name "My New Vlan Name" -description "My Description change by PowerArubaCX"

        Change the name and description of vlan id 44

        .EXAMPLE
        Get-ArubaCXVlan -id 44 | Set-ArubaCXVlan -voice -admin up

        Configure Vlan 44 with voice vlan and set admin to up

        .EXAMPLE
        Get-ArubaCXVlan -id 44 | Set-ArubaCXVlan -vsx_sync -voice -admin down

        Configure Vlan 44 with enable VSX sync and set admin to status

        .EXAMPLE
        $vlan = Get-ArubaCXVlan -id 44 -selector writable
        PS> $vlan.name = "My Vlan"
        PS> $vlan | Set-ArubaCXVlan -use_pipeline

        Configure Vlan 44 name using pipeline (can be only with selector equal writable)
    #>
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [ValidateRange(1, 4096)]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        [ValidateScript( { Confirm-ArubaCXVlan $_ })]
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
            #Remove id from vlan (can not be modified)
            $vlan.psobject.Properties.remove("id")
            $_vlan = $vlan
        }
        else {
            $_vlan = Get-ArubaCXVlan -id $id -selector writable
        }

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

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_vlan -connection $connection
        $response

        Get-ArubaCXVlan -id $id -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXVlan {

    <#
        .SYNOPSIS
        Remove a vlan on Aruba CX Switch

        .DESCRIPTION
        Remove a vlan on Aruba CX Switch

        .EXAMPLE
        $vlan = Get-ArubaCXVlan -name MyVlan
        PS C:\>$vlan | Remove-ArubaCXVlan

        Remove vlan named MyVlan

        .EXAMPLE
        Remove-ArubaCXVlan -id 23 -confirm:$false

        Remove Vlan with id 23 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        [ValidateScript( { Confirm-ArubaCXVlan $_ })]
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