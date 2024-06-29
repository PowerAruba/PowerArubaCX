#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXNeighbors {


    <#
      .SYNOPSIS
      Get list of Neighbors (ARP Table)

      .DESCRIPTION
      Get list of Neighbors (Mac Address, IP Address, type, vlan...)

      .EXAMPLE
      Get-ArubaCXNeighbors

      Get Neighbors (ARP Table) information on all VRF

      .EXAMPLE
      Get-ArubaCXNeighbors -vrf MyVRF

      Get Neighbors (ARP Table) information on vrf MyVRF

      .EXAMPLE
      Get-ArubaCXVrfs MyVRF | Get-ArubaCXNeighbors

      Get Neighbors (ARP Table) information on vrf MyVRF (using pipeline)

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCXVrfs $_ })]
        [psobject]$vrf_pp,
        [Parameter(Mandatory = $false, position = 1)]
        [String]$vrf = "*",
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

        #get vrf name from vrf_pp ps object (passed by pipeline)
        if ($vrf_pp) {
            $vrf = $vrf_pp.name
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

        $uri = "system/vrfs/$vrf/neighbors"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}