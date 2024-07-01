#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXMACs {


    <#
      .SYNOPSIS
      Get list of MACs (MAC Address Table)

      .DESCRIPTION
      Get list of MACs (Mac Address, type, vlan...)

      .EXAMPLE
      Get-ArubaCXMACs

      Get Neighbors (MAC Address Table) information on all Vlans

      .EXAMPLE
      Get-ArubaCXMACs -vlan MyVlan

      Get Neighbors (MAC Address Table) information on vlan MyVlan

      .EXAMPLE
      Get-ArubaCXVlans MyVlan | Get-ArubaCXMACs

      Get Neighbors (MAC Address Table) information on vlan MyVlan (using pipeline)

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCXVlans $_ })]
        [psobject]$vlan_pp,
        [Parameter(Mandatory = $false, position = 1)]
        [String]$vlan = "*",
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

        #get vlan id from vlan_pp ps object (passed by pipeline)
        if ($vlan_pp) {
            $vlan = $vlan_pp.id
        }

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

        $uri = "system/vlans/$vlan/macs"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}