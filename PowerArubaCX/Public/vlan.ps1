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
    #>
    Param(
        [Parameter (Mandatory = $true)]
        [ValidateRange(1, 4096)]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [string]$type,
        [Parameter (Mandatory = $false)]
        [string]$admin,
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

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_vlan | add-member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_vlan | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('type') ) {
            $_vlan | add-member -name "type" -membertype NoteProperty -Value $type
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            $_vlan | add-member -name "admin" -membertype NoteProperty -Value $admin
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_vlan -connection $connection
        $response
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
    #>
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
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

        $uri = "system/vlans"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}