#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCXSystem {

    <#
        .SYNOPSIS
        Get System info about ArubaCX Switch

        .DESCRIPTION
        Get System Info (name, dns_servers...)

        .EXAMPLE
        Get-ArubaCXSystem

        Get system info on the switch

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

        $uri = "rest/$Script:Api/system"

        $response = invoke-ArubaCXRestMethod -method "GET" -uri $uri @invokeParams
        $response
    }

    End {
    }
}