#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXDHCPRelay {

    <#
        .SYNOPSIS
        Add Aruba CX DHCP Relay

        .DESCRIPTION
        Add DHCP Relay (IP, port, vrf...)

        .EXAMPLE
        Add-ArubaCXDHCPRelay -port vlan1 -ipv4_ucast_server 192.2.0.1

        Add IP DHCP relay 192.2.0.1 on port(interface) vlan1 with default vrf

        .EXAMPLE
        Add-ArubaCXDHCPRelay -port vlan2 -ipv4_ucast_server 192.2.0.1, 192.2.0.2 -vrf MyVRF

        Add IP DHCP relay 192.2.0.1, 192.2.0.2 on port(interface) vlan2 with default MyVRF
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true)]
        [string]$port,
        [Parameter (Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter (Mandatory = $true)]
        [string[]]$ipv4_ucast_server,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/dhcp_relays"

        $_dhcprelay = new-Object -TypeName PSObject

        $_vrf = New-Object -TypeName PSObject
        $vrf_uri = "/rest/" + $($connection.api_version) + "/system/vrfs/" + $vrf
        $_vrf | Add-Member -name $vrf -membertype NoteProperty -Value $vrf_uri
        $_dhcprelay | Add-Member -name "vrf" -membertype NoteProperty -Value $_vrf

        $_port = New-Object -TypeName PSObject
        $port_uri = "/rest/" + $($connection.api_version) + "/system/interfaces/" + $port
        $_port | Add-Member -name $port -membertype NoteProperty -Value $port_uri
        $_dhcprelay | Add-Member -name "port" -membertype NoteProperty -Value $_port

        $_dhcprelay | Add-Member -name "ipv4_ucast_server" -membertype NoteProperty -Value @($ipv4_ucast_server)

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_dhcprelay -connection $connection
        $response

        Get-ArubaCXDHCPRelay -port $port -vrf $vrf -connection $connection
    }

    End {
    }
}

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

function Set-ArubaCXDHCPRelay {

    <#
        .SYNOPSIS
        Configure Aruba CX DHCP Rleay

        .DESCRIPTION
        Configure DHCP Relay (ipv4_ucast_server)

        .EXAMPLE
        Get-ArubaCXDHCPRelay -port vlan1 | Set-ArubaCXDHCPRelay -ipv4_ucast_server 192.2.0.3

        Change the ipv4_ucast_server (192.2.0.3) on DHCP Relay vlan1 (vrf default)

        .EXAMPLE
        Get-ArubaCXDHCPRelay -port vlan1 | Set-ArubaCXDHCPRelay -ipv4_ucast_server 192.2.0.3, 192.2.0.4

        Change the ipv4_ucast_server (192.2.0.3, 192.2.0.4) on DHCP Relay vlan2 and vrf myVRF

    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "portvrf")]
        [string]$port,
        [Parameter (Mandatory = $false, ParameterSetName = "portvrf")]
        [string]$vrf = "default",
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "dhcprelay")]
        [ValidateScript( { Confirm-ArubaCXDHCPRelay $_ })]
        [psobject]$dhcprelay,
        [Parameter (Mandatory = $false)]
        [string[]]$ipv4_ucast_server,
        [Parameter (Mandatory = $false)]
        [switch]$use_pipeline,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get dhcprelay vrf/port from dhcprelay ps object
        if ($dhcprelay) {
            #Get the name of properties...
            $port = $dhcprelay.port.psobject.properties.name
            $vrf = $dhcprelay.vrf.psobject.properties.name
        }

        $uri = "system/dhcp_relays/${vrf},${port}"

        if ($use_pipeline) {
            $_dhcprelay = $dhcprelay
        }
        else {
            $_dhcprelay = Get-ArubaCXDHCPRelay -port $port -vrf $vrf -selector writable -connection $connection
        }

        if ( $PsBoundParameters.ContainsKey('ipv4_ucast_server') ) {
            $_dhcprelay.ipv4_ucast_server = @($ipv4_ucast_server)
        }

        if ($PSCmdlet.ShouldProcess("DHCP Relay", "Configure DHCP Relay ${port} on ${vrf}")) {
            $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_dhcprelay -connection $connection
            $response
        }

        Get-ArubaCXDHCRelay -port $port -vrf $vrf -connection $connection
    }

    End {
    }
}


function Remove-ArubaCXDHCPRelay {

    <#
        .SYNOPSIS
        Remove a DHCP Relay on Aruba CX Switch

        .DESCRIPTION
        Remove a DHCP Relay on Aruba CX Switch

        .EXAMPLE
        $dhcprelay = Get-ArubaCXDHCPRelay -port vlan1
        PS C:\>$dhcprelay | Remove-ArubaCXDHCPRelay

        Remove DHCP Relay configured on port/interface vlan1

        .EXAMPLE
        Remove-ArubaCXDHCPRelay -port vlan1 -vrf myVRF -confirm:$false

        Remove DHCP Relay with port vlan1 and vrf myVRF  with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "portvrf")]
        [string]$port,
        [Parameter (Mandatory = $false, ParameterSetName = "portvrf")]
        [string]$vrf = "default",
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "dhcprelay")]
        [ValidateScript( { Confirm-ArubaCXDHCPRelay $_ })]
        [psobject]$dhcprelay,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get dhcprelay vrf/port from dhcprelay ps object
        if ($dhcprelay) {
            #Get the name of properties...
            $port = $dhcprelay.port.psobject.properties.name
            $vrf = $dhcprelay.vrf.psobject.properties.name
        }

        $uri = "system/dhcp_relays/${vrf},${port}"

        if ($PSCmdlet.ShouldProcess("DHCP Relay", "Remove DHCP Relay ${port} on ${vrf}")) {
            Write-Progress -activity "Remove DHCP Relay"
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove DHCP Relay" -completed
        }
    }

    End {
    }
}