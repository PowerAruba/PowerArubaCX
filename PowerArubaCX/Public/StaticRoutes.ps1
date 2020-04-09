#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXStaticRoutes {

    <#
        .SYNOPSIS
        Add Aruba CX Static Static Route

        .DESCRIPTION
        Add Static Route (address_family, prefix, static_nexthops, type)

        .EXAMPLE
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 192.0.2.0 -prefix_ip4_mask 24 -type forward

        Add Static Route type forward for network 192.0.2.0/24 (on default vrf)

        .EXAMPLE
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 192.0.2.0 -prefix_ip4_mask 24 -type blackhole -vrf MyVrf

        Add Static Route type blackhole for network 192.0.2.0/24 on MyVRF

        .EXAMPLE
        Get-ArubaCXVrf MyVRF | Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 192.0.2.0 -prefix_ip4_mask 24 -type rject

        Add Static Route type reject for network 192.0.2.0/24 on MyVRF (using pipeline)
    #>
    Param(
        [Parameter (Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCXVrfs $_ })]
        [psobject]$vrf_pp,
        [Parameter(Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter (Mandatory = $true)]
        [ValidateSet('ipv4', IgnoreCase = $false)]
        [string]$address_family = "ipv4",
        [Parameter (Mandatory = $true)]
        [ipaddress]$prefix_ip4,
        [Parameter (Mandatory = $true)]
        [ValidateRange(0, 32)]
        [int]$prefix_ip4_mask,
        [Parameter (Mandatory = $true)]
        [ValidateSet('forward', 'reject', 'blackhole')]
        [string]$type,
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

        if ( -not ($prefix_ip4.AddressFamily -eq "InterNetwork" )) {
            Throw "You need to specify a IPv4 Address"
        }
        $prefix = $prefix_ip4.ToString() + "/" + $prefix_ip4_mask
        #replace / by %2F
        $prefix = $prefix -replace '/', '%2F'

        $uri = "system/vrfs/$vrf/static_routes"

        $_sr = new-Object -TypeName PSObject

        $_sr | add-member -name "address_family" -membertype NoteProperty -Value $address_family

        $_sr | add-member -name "prefix" -membertype NoteProperty -Value $prefix

        $_sr | add-member -name "type" -membertype NoteProperty -Value $type

        $_sr | add-member -name "vrf" -membertype NoteProperty -Value ("/rest/" + $($connection.version) + "/system/vrfs/" + $vrf)

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_sr -connection $connection
        $response

        Get-ArubaCXStaticRoutes -vrf $vrf -prefix $prefix -connection $connection
    }

    End {
    }
}
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

function Remove-ArubaCXStaticRoutes {

    <#
        .SYNOPSIS
        Remove a Static Route on Aruba CX Switch

        .DESCRIPTION
        Remove a Static Route on Aruba CX Switch

        .EXAMPLE
        $sr = Get-ArubaCXStaticRoutes -prefix 192.0.2.0/24
        PS C:\>$sr | Remove-ArubaCXStaticRoutes -vrf default

        Remove Static Route with prefix 192.0.2.0/24

        .EXAMPLE
        Remove-ArubaCXStaticRoutes -prefix 192.0.2.0/24 -confirm:$false -vrf MyVRF

        Remove Static Route 192.0.2.0/24 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "name")]
        [string]$prefix,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "route")]
        [ValidateScript( { Confirm-ArubaCXStaticRoutes $_ })]
        [psobject]$sr,
        [Parameter(Mandatory = $true)]
        [string]$vrf,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get prefix from static route ps object
        if ($sr) {
            $prefix = $sr.prefix
        }

        #replace / by %2F
        $prefix2 = $prefix -replace '/', '%2F'

        $uri = "system/vrfs/$vrf/static_routes/$prefix2"

        if ($PSCmdlet.ShouldProcess("Static Route", "Remove Static Route ${prefix}")) {
            Write-Progress -activity "Remove Static Route"
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Static Route" -completed
        }
    }

    End {
    }
}