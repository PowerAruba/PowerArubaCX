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

        Get-ArubaCXVlan -id $id
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
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 4096)]
        [int]$id,
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

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $uri += "/$id"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
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
        $vlan = Get-ArubaCXVlan -id 23
        PS C:\>$vlan | Remove-ArubaCXVlan

        Remove vlan with id 23

        .EXAMPLE
        Remove-ArubaCXVlan -id 23 -confirm:$false

        Remove Vlan with id 23 with no confirmation
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        #[ValidateScript( { Confirm-ArubaCXVlans $_ })]
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