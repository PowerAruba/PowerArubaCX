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

    #>
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
        [Int]$depth,
        [Parameter(Mandatory = $false)]
        [ValidateSet("configuration", "status", "statistics")]
        [String]$selector,
        [Parameter(Mandatory = $false)]
        [String[]]$attributes
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

        $uri = "rest/v1/system/ports"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' @invokeParams
        $response
    }

    End {
    }
}