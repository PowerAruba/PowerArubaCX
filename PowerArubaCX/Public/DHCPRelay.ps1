#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaCXDHCPRelay {

    <#
        .SYNOPSIS
        Get list of all Aruba CX DHCP Relay

        .DESCRIPTION
        Get list of all Aruba CX DHCP Relay

        .EXAMPLE
        Get-ArubaCXDHCPRelay

        Get list of all DHCP Relay (IP, port, vrf...)

        .EXAMPLE
        Get-ArubaCXDHCPRelay -port vlan1

        Get vlan with with port (interface) vlan 1 (and vrf default)

        .EXAMPLE
        Get-ArubaCXDHCPRelay -port vlan2 -vrf MyVrf

        Get vlan with with port (interface) vlan 2 (and vrf MyVRF)
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $false)]
        [string]$port,
        [Parameter (Mandatory = $false)]
        [string]$vrf = 'default',
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
            #You need to specify a vlan for use writable selector (it is not possible to use on collections...)
            if ($PSCmdlet.ParameterSetName -eq "Default" -and $selector -eq "writable") {
                Throw "You need to specify a vlan (id or name) to use writable selector"
            }
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "system/dhcp_relays"

        if ($PsBoundParameters.ContainsKey('port')) {
            $uri += "/$vrf,$port"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        $response

    }

    End {
    }
}

