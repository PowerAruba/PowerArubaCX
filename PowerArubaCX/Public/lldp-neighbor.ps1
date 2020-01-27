#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXLLDPNeighbor {

    <#
      .SYNOPSIS
      Get list of LLDP Neighbor

      .DESCRIPTION
      Get list of LLDP Neighbor (Chassis name, IP Address, description...)

      .EXAMPLE
      Get-ArubaCXLLDPNeighbor 1/1/1

      Get LLDP Neighbor information of port 1/1/1

    #>
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$neighbor,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
        [Int]$depth,
        [Parameter(Mandatory = $false)]
        [ValidateSet("configuration", "status", "statistics")]
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

        $neighbor = $neighbor -replace '/', '%2F'
        $uri = "system/interfaces/$neighbor/lldp_neighbors"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection  @invokeParams
        $response
    }

    End {
    }
}