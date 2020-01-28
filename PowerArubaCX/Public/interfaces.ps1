#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Interfacess

      .DESCRIPTION
      Get list of all Aruba CX Interfaces (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXIntefarces

      Get list of all interface (lag/port/vlan)

    #>
    Param(
        [Parameter(Mandatory = $false, position = 1)]
        [String]$interface,
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

        $uri = "system/interfaces"

        if ( $PsBoundParameters.ContainsKey('interface') ) {
            $interface = $interface -replace '/', '%2F'
            $uri += "/$interface"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}


function Set-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Confgure Aruba CX Interfaces

      .DESCRIPTION
      Configure Aruba CX Interfaces (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Set-ArubaCXInterfaces -interface 1/1/1 -description "Changed by PowerArubaCX"

      Set the description for the Interface 1/1/1

      .EXAMPLE
      Set-ArubaCXInterfaces -interface 1/1/1 -admin up

      Set the admin status to up for the Interface 1/1/1

      .EXAMPLE
      Set-ArubaCXInterfaces -interface 1/1/1 -routing:$false

      Set the routing to disable for the Interface 1/1/1
    #>
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$interface,
        [Parameter(Mandatory = $false)]
        [ValidateSet('up', 'down')]
        [string]$admin,
        [Parameter(Mandatory = $false)]
        [string]$description,
        [Parameter(Mandatory = $false)]
        [switch]$routing,
        [Parameter(Mandatory = $false)]
        [ValidateSet('access', 'native-untagged')]
        [string]$vlan_mode,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4096)]
        [int]$vlan_tag,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"
        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        $_interface = Get-ArubaCXInterfaces $interface -selector writable

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_interface.description = $description
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            if ($_interface.user_config.admin -eq $null) {
                $_interface.user_config | Add-member -name "admin" -membertype NoteProperty -Value ""
            }
            $_interface.user_config.admin = $admin
        }

        if ( $PsBoundParameters.ContainsKey('routing') ) {
            if ($routing) {
                $_interface.routing = $true
            }
            else {
                $_interface.routing = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vlan_mode') ) {
            $_interface.vlan_mode = $vlan_mode
        }

        if ( $PsBoundParameters.ContainsKey('vlan_tag') ) {
            $_vlan_tag = New-Object -TypeName PSObject
            $_vlan_tag | Add-member -name $vlan_tag -membertype NoteProperty -Value "/rest/" + $($connection.version) + "/system/vlans/" + $vlan_tag
            $_interface.vlan_tag = $_vlan_tag
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_interface -connection $connection
        $response
        Get-ArubaCXInterfaces $interface
    }

    End {
    }
}