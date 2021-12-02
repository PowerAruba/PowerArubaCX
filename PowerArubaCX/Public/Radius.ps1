#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXRadiusServer {

    <#
        .SYNOPSIS
        Add Aruba CX RADIUS Server

        .DESCRIPTION
        Add RADIUS Server (ip, group, port...)

        .EXAMPLE
        Add-ArubaCXRadiusServer -address 192.2.0.1 -port 1812 -group PowerArubaCX -default_group_priority 1

        Add RADIUS Server with ip 192.2.0.1 and port 1812 in RADIUS group PowerArubaCX

        .EXAMPLE
        Add-ArubaCXRadiusServer -address 192.2.0.1 -port 1812 -group PowerArubaCX -default_group_priority 10 -timeout 10 -passkey ExampleRADIUS

        Add RADIUS Server with ip 192.2.0.1 and port 1812 in RADIUS group PowerArubaCX with timeout set to 10 and passkey as ExampleRADIUS
    #>
    Param(
        [Parameter (Mandatory = $true)]
        [string]$address,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$port = 1812,
        [Parameter (Mandatory = $false)]
        [ValidateSet('pap')]
        [string]$auth_type = "pap",
        [Parameter (Mandatory = $false)]
        [ValidateSet('udp','tcp')]
        [string]$port_type = "udp",
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 9223372036854775807)]
        [int64]$default_group_priority = 10,
        [Parameter (Mandatory = $false)]
        [string]$group = "tacacs",
        [Parameter (Mandatory = $false)]
        [string]$passkey,
        [Parameter (Mandatory = $false)]
        [string]$cppm_user_id,
        [Parameter (Mandatory = $false)]
        [string]$cppm_password,
        [Parameter (Mandatory = $false)]
        [int]$timeout,
        [Parameter (Mandatory = $false)]
        [int]$retries,
        [Parameter (Mandatory = $false)]
        [switch]$tracking_enable,
        [Parameter (Mandatory = $false)]
        [int]$user_group_priority,
        [Parameter (Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/vrfs/${vrf}/radius_servers"

        $_radius = new-Object -TypeName PSObject

        $_radius | add-member -name "address" -membertype NoteProperty -Value $address

        $_radius | add-member -name "port" -membertype NoteProperty -Value $port

        $_radius | add-member -name "vrf" -membertype NoteProperty -Value ("/rest/" + $($connection.version) + "/system/vrfs/" + $vrf)
    
        $_radius | add-member -name "default_group_priority" -membertype NoteProperty -Value $default_group_priority

        $_group = @()

        $_group += "/rest/" + $($connection.version) + "/system/aaa_server_groups/" + $group

        $_radius | add-member -name "group" -membertype NoteProperty -Value $_group

        $_radius | add-member -name "auth_type" -membertype NoteProperty -Value $auth_type

        $_radius | add-member -name "port_type" -membertype NoteProperty -Value $port_type

        if ( $PsBoundParameters.ContainsKey('cppm_user_id') -and $PsBoundParameters.ContainsKey('cppm_password') ) {
            $_cppm = new-Object -TypeName PSObject

            $_cppm | add-member -name "user_id" -membertype NoteProperty -Value $cppm_user_id

            $_cppm | add-member -name "password" -membertype NoteProperty -Value $cppm_password

            $_radius | add-member -name "clearpass" -membertype NoteProperty -Value $_cppm
        }

        if ( $PsBoundParameters.ContainsKey('passkey') ) {
            $_radius | add-member -name "passkey" -membertype NoteProperty -Value $passkey
        }

        if ( $PsBoundParameters.ContainsKey('timeout') ) {
            $_radius | add-member -name "timeout" -membertype NoteProperty -Value $timeout
        }

        if ( $PsBoundParameters.ContainsKey('retries') ) {
            $_radius | add-member -name "retries" -membertype NoteProperty -Value $retries
        }

        if ( $PsBoundParameters.ContainsKey('user_group_priority') ) {
            $_radius | add-member -name "user_group_priority" -membertype NoteProperty -Value $user_group_priority
        }

        if ( $PsBoundParameters.ContainsKey('tracking_enable') ) {
            if ($tracking_enable) {
                $_radius | add-member -name "tracking_enable" -membertype NoteProperty -Value $true
            }
            else {
                $_radius | add-member -name "tracking_enable" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_radius -connection $connection
        $response

        Get-ArubaCXRadiusServer -address $address -port $port -port_type $port_type -vrf $vrf

    }

    End {
    }
}

function Get-ArubaCXRadiusServer {

    <#
        .SYNOPSIS
        Get list of RADIUS Server configured

        .DESCRIPTION
        Get list of RADIUS Server configured (ip, port, port_type...)

        .EXAMPLE
        Get-ArubaCXRadiusServer -vrf default

        Get list of RADIUS Server configured (ip, port_type, port...) on default vrf

        .EXAMPLE
        Get-ArubaCXRadiusServer -address 192.2.0.1

        Get RADIUS Server with ip 192.2.0.1
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [ipaddress]$address,
        [Parameter (Mandatory = $false)]
        [int]$port = 1812,
        [Parameter (Mandatory = $false)]
        [ValidateSet('udp','tcp')]
        [string]$port_type = "udp",
        [Parameter (Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4)]
        [Int]$depth,
        [Parameter(Mandatory = $false, ParameterSetName = "address")]
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
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        if ($PsBoundParameters.ContainsKey('address')) {
            $uri = "system/vrfs/${vrf}/radius_servers/${address},${port},${port_type}"
        }
        else {
            $uri = "system/vrfs/${vrf}/radius_servers"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        $response

    }

    End {
    }
}

function Set-ArubaCXRadiusServer {

    <#
        .SYNOPSIS
        Configure RADIUS Server ArubaCX Switch

        .DESCRIPTION
        Configure RADIUS Server (Timeout, port...)

        .EXAMPLE
        Get-ArubaCXRadiusServer -address 192.2.0.1 | Set-ArubaCXRadiusServer -timeout 15

        Configure timeout on RADIUS Server

        .EXAMPLE
        Get-ArubaCXRadiusServer -address 192.2.0.1 | Set-ArubaCXRadiusServer -group radius

        Configure group on RADIUS Server

        .EXAMPLE
        Get-ArubaCXRadiusServer -address 192.2.0.1 | Set-ArubaCXRadiusServer -passkey ExampleRADIUS

        Configure passkey on RADIUS Server

        .EXAMPLE
        Get-ArubaCXRadiusServer -address 192.2.0.1 | Set-ArubaCXRadiusServer -default_group_priority 10 -group PowerArubaCX -passkey ExampleRADIUS -timeout 15 -tacking_enable -user_group_priority 1

        Configure passkey, timeout, tacking enable and user group priority on RADIUS Server
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXRadiusServer $_ })]
        [psobject]$radius,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [string]$address,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [int]$port,
        [Parameter (Mandatory = $false)]
        [ValidateSet('pap')]
        [string]$auth_type,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [ValidateSet('udp','tcp')]
        [string]$port_type,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 9223372036854775807)]
        [int]$default_group_priority,
        [Parameter (Mandatory = $false)]
        [string]$group = "radius",
        [Parameter (Mandatory = $false)]
        [string]$passkey,
        [Parameter (Mandatory = $false)]
        [string]$cppm_user_id,
        [Parameter (Mandatory = $false)]
        [string]$cppm_password,
        [Parameter (Mandatory = $false)]
        [int]$timeout = 10,
        [Parameter (Mandatory = $false)]
        [int]$retries = 1,
        [Parameter (Mandatory = $false)]
        [switch]$tracking_enable,
        [Parameter (Mandatory = $false)]
        [int]$user_group_priority = 1,
        [Parameter (Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )


    Begin {
    }

    Process {

        $_radius = @{ }

        if ($radius) {
            $address = $radius.address
            $port = $radius.port
            $port_type = $radius.port_type
        }

        $uri = "system/vrfs/${vrf}/radius_servers/${address},${port},${port_type}"

        $_radius = Get-ArubaCXRadiusServer -address $address -port $port -port_type $port_type -selector writable

        if ( $PsBoundParameters.ContainsKey('auth_type') ) {
            $_radius.auth_type = $auth_type
        }
        if ( $PsBoundParameters.ContainsKey('default_group_priority') ) {
            $_radius.default_group_priority = $default_group_priority
        }

        $_group = @()

        $_group += "/rest/" + $($connection.version) + "/system/aaa_server_groups/" + $group

        $_radius.group = $_group

        if ( $PsBoundParameters.ContainsKey('cppm_user_id') -and $PsBoundParameters.ContainsKey('cppm_password') ) {
            $_cppm = new-Object -TypeName PSObject

            $_cppm | add-member -name "password" -membertype NoteProperty -Value $cppm_password

            $_cppm | add-member -name "user_id" -membertype NoteProperty -Value $cppm_user_id

            $_radius.clearpass = $_cppm
        }

        if ( $PsBoundParameters.ContainsKey('passkey') ) {
            $_radius.passkey = $passkey
        }

        if ( $PsBoundParameters.ContainsKey('timeout') ) {
            $_radius.timeout = $timeout
        }

        if ( $PsBoundParameters.ContainsKey('retries') ) {
            $_radius.retries = $retries
        }

        if ( $PsBoundParameters.ContainsKey('tracking_enable') ) {
            if ($tracking_enable) {
                $_radius.tracking_enable = $true
            }
            else {
                $_radius.tracking_enable = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('user_group_priority') ) {
            $_radius.user_group_priority = $user_group_priority
        }

        if ($PSCmdlet.ShouldProcess($_radius.address, 'Configure RADIUS Server')) {
            Invoke-ArubaCXRestMethod -method "PUT" -body $_radius -uri $uri -connection $connection
        }

        Get-ArubaCXRadiusServer -address $address -port $port -port_type $port_type -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXRadiusServer {

    <#
        .SYNOPSIS
        Remove a RADIUS Server on Aruba CX Switch

        .DESCRIPTION
        Remove a RADIUS Server on Aruba CX Switch

        .EXAMPLE
        $rs = Get-ArubaCXArubaCXRadiusServer -address 192.2.0.1
        PS C:\>$rs | Remove-ArubaCXRadiusServer

        Remove RADIUS Server with address 192.0.2.1

        .EXAMPLE
        Remove-ArubaCXRadiusServer -address 192.2.0.1 -confirm:$false -vrf default
        Remove RADIUS Server 192.0.2.1 on default vrf with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [string]$address,
        [Parameter (Mandatory = $false, ParameterSetName = "address")]
        [int]$port = 1812,
        [Parameter (Mandatory = $false, ParameterSetName = "address")]
        [ValidateSet('udp','tcp')]
        [string]$port_type = "udp",
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXRadiusServer $_ })]
        [psobject]$rs,
        [Parameter(Mandatory = $false, ParameterSetName = "address")]
        [string]$vrf = "default",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get address, port, port_type and vrf from RADIUS Server ts object
        if ($rs) {
            $address = $rs.address
            $port = $rs.port
            $port_type = $rs.port_type
        }

        $uri = "system/vrfs/${vrf}/radius_servers/${address},${port},${port_type}"

        if ($PSCmdlet.ShouldProcess("RADIUS Server (VRF: ${vrf})", "Remove ${address},${port},${port_type}")) {
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
} 