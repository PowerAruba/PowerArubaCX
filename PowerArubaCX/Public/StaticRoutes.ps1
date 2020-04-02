#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCXStaticRoutes {

    <#
        .SYNOPSIS
        Get list of all Aruba CX Route

        .DESCRIPTION
        Get list of all Aruba CX Static Rout (address_family, prefix, static_nexthops, type)

        .EXAMPLE
        Get-ArubaCXStaticRoutes

        Get list of all Static Route information (address_family, prefix, static_nexthops, type)

        .EXAMPLE
        Get-ArubaCXStaticRoutes -prefix 192.0.2.0/24

        Get Static Route information of prefix 192.0.2.0/24

        .EXAMPLE
        Get-ArubaCXVrfs -vrf MyVRF | Get-ArubaCXStaticRoutes

        Get Static Route information from VRF named MyVRF (using pipeline)

        .EXAMPLE
        Get-ArubaCXStaticRoutes -vrf MyVRF

        Get Static Route information from VRF named MyVRF
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "prefix", position = "1")]
        [string]$prefix,
        [Parameter (Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCXVrfs $_ })]
        [psobject]$vrf_pp,
        [Parameter(Mandatory = $false)]
        [string]$vrf = "default",
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

        #get vrf name from vrf_pp ps object (based by pipeline)
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

        $uri = "system/vrfs/$vrf/static_routes"

        # you can directly filter by prefix
        if ( $PsBoundParameters.ContainsKey('prefix') ) {
            #replace / by %2F
            $prefix = $prefix -replace '/', '%2F'
            $uri += "/$prefix"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        #Add id parameter when use writable type selector
        if ( $PsBoundParameters.ContainsKey('selector') -and $PsBoundParameters.ContainsKey('prefix') -and $selector -eq "writable" ) {
            $response | add-member -name "prefix" -membertype NoteProperty -Value $prefix
        }

        $response
    }

    End {
    }
}