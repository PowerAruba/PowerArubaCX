#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXPorts {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Ports

      .DESCRIPTION
      Get list of all Aruba CX Ports (name, Mode, vlan, description....)

      .EXAMPLE
      Get-ArubaCXPorts

      Get list of all ports

      .EXAMPLE
      Get-ArubaCXPorts -port 1/1/1 -selector statistics

      Get port 1/1/1 statitics information
    #>
    Param(
        [Parameter(Mandatory = $false, position = 1)]
        [String]$port,
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

        $uri = "system/ports"

        if ( $PsBoundParameters.ContainsKey('port') ) {
            $port = $port -replace '/', '%2F'
            $uri += "/$port"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection  @invokeParams
        $response
    }

    End {
    }
}