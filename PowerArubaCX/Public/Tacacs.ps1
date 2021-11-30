#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXTacacsServer {

    <#
        .SYNOPSIS
        Add Aruba CX Tacacs Server

        .DESCRIPTION
        Add tacacs server (ip, group, port...)

        .EXAMPLE
        Add-ArubaCXTacacsServer -address 192.2.0.1 -port 49 -group Clearpass -default_group_priority 10

        Add tacacs server with ip 192.2.0.1 and port 49 in Tacacs group Clearpass
    #>
    Param(
        [Parameter (Mandatory = $true)]
        [string]$address,
        [Parameter (Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [int]$port,
        [Parameter (Mandatory = $false)]
        [ValidateSet('pap')]
        [string]$auth_type = "pap",
        [Parameter (Mandatory = $true)]
        [ValidateRange(1, 9223372036854775807)]
        [int]$default_group_priority,
        [Parameter (Mandatory = $true)]
        [string]$group,
        [Parameter (Mandatory = $false)]
        [string]$passkey,
        [Parameter (Mandatory = $false)]
        [int]$timeout,
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

        $uri = "system/vrfs/${vrf}/tacacs_servers"

        $_tacacs = new-Object -TypeName PSObject

        $_tacacs | add-member -name "address" -membertype NoteProperty -Value $address

        $_tacacs | add-member -name "tcp_port" -membertype NoteProperty -Value $port

        $_tacacs | add-member -name "vrf" -membertype NoteProperty -Value ("/rest/" + $($connection.version) + "/system/vrfs/" + $vrf)
    
        $_tacacs | add-member -name "default_group_priority" -membertype NoteProperty -Value $default_group_priority

        $_group = @()

        $_group += "/rest/" + $($connection.version) + "/system/aaa_server_groups/" + $group

        $_tacacs | add-member -name "group" -membertype NoteProperty -Value $_group

        $_tacacs | add-member -name "auth_type" -membertype NoteProperty -Value $auth_type

        if ( $PsBoundParameters.ContainsKey('passkey') ) {
            $_tacacs | add-member -name "passkey" -membertype NoteProperty -Value $passkey
        }

        if ( $PsBoundParameters.ContainsKey('timeout') ) {
            $_tacacs | add-member -name "timeout" -membertype NoteProperty -Value $timeout
        }

        if ( $PsBoundParameters.ContainsKey('user_group_priority') ) {
            $_tacacs | add-member -name "user_group_priority" -membertype NoteProperty -Value $user_group_priority
        }

        if ( $PsBoundParameters.ContainsKey('tracking_enable') ) {
            if ($tracking_enable) {
                $_tacacs | add-member -name "tracking_enable" -membertype NoteProperty -Value $true
            }
            else {
                $_tacacs | add-member -name "tracking_enable" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_tacacs -connection $connection
        $response

        Get-ArubaCXTacacsServer -address $address -port $port -vrf $vrf

    }

    End {
    }
}

function Get-ArubaCXTacacsServer {

    <#
        .SYNOPSIS
        Get list of tacacs server configured

        .DESCRIPTION
        Get list of tacacs server configured (ip, group, port...)

        .EXAMPLE
        Get-ArubaCXTacacsServer -vrf default

        Get list of tacacs server configured (ip, group, port...) on default vrf

        .EXAMPLE
        Get-ArubaCXTacacsServer -address 192.2.0.1 -port 49

        Get tacacs server with ip 192.2.0.1 and port 49
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [ipaddress]$address,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [int]$port,
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
        else {
            #by default set depth to 2 to show items
            $invokeParams.add( 'depth', 2 )
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

        if ($PsBoundParameters.ContainsKey('address') -and $PsBoundParameters.ContainsKey('port')) {
            $uri = "system/vrfs/${vrf}/tacacs_servers/${address},${port}"
        }
        else {
            $uri = "system/vrfs/${vrf}/tacacs_servers"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        $response

    }

    End {
    }
}

function Set-ArubaCXTacacsServer {

    <#
        .SYNOPSIS
        Configure Tacacs Server ArubaCX Switch

        .DESCRIPTION
        Configure Tacacs Server (Timeout, port...)

        .EXAMPLE
        Set-ArubaCXTacacsServer -timeout 15 -address 192.2.0.1 -port 49

        Configure timeout on tacacs server

        .EXAMPLE
        Set-ArubaCXTacacsServer -group tacacs -address 192.2.0.1 -port 49

        Configure group on tacacs server

        .EXAMPLE
        Set-ArubaCXTacacsServer -passkey ExampleTacacs -address 192.2.0.1 -port 49

        Configure passkey on tacacs server

        .EXAMPLE
        Get-ArubaCXTacacsServer -address 192.2.0.1 -port 49 | Set-ArubaCXTacacsServer -default_group_priority 10 -group PowerArubaCX -passkey ExampleTacacs -timeout 15 -tacking_enable -user_group_priority 1

        Configure passkey on tacacs server
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXTacacsServer $_ })]
        [psobject]$tacacs,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [string]$address,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [int]$port,
        [Parameter (Mandatory = $false)]
        [ValidateSet('pap')]
        [string]$auth_type,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 9223372036854775807)]
        [int]$default_group_priority,
        [Parameter (Mandatory = $false)]
        [string]$group = "tacacs",
        [Parameter (Mandatory = $false)]
        [string]$passkey,
        [Parameter (Mandatory = $false)]
        [int]$timeout = 10,
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

        $_tacacs = @{ }

        if ($tacacs) {
            $address = $tacacs.address
            $port = $tacacs.tcp_port
        }

        $uri = "system/vrfs/${vrf}/tacacs_servers/${address},${port}"

        $_tacacs = Get-ArubaCXTacacsServer -address $address -port $port -selector writable

        if ( $PsBoundParameters.ContainsKey('auth_type') ) {
            $_tacacs | add-member -name "auth_type" -membertype NoteProperty -Value $auth_type -Force
        }
        if ( $PsBoundParameters.ContainsKey('default_group_priority') ) {
            $_tacacs | add-member -name "default_group_priority" -membertype NoteProperty -Value $default_group_priority -Force
        }

        $_group = @()

        $_group += "/rest/" + $($connection.version) + "/system/aaa_server_groups/" + $group

        $_tacacs | add-member -name "group" -membertype NoteProperty -Value $_group -Force

        if ( $PsBoundParameters.ContainsKey('passkey') ) {
            $_tacacs | add-member -name "passkey" -membertype NoteProperty -Value $passkey -Force
        }

        $_tacacs | add-member -name "timeout" -membertype NoteProperty -Value $timeout -Force

        if ( $PsBoundParameters.ContainsKey('tracking_enable') ) {
            if ($tracking_enable) {
                $_tacacs | add-member -name "tracking_enable" -membertype NoteProperty -Value $true -Force
            }
            else {
                $_tacacs | add-member -name "tracking_enable" -membertype NoteProperty -Value $false -Force
            }
        }

        $_tacacs | add-member -name "user_group_priority" -membertype NoteProperty -Value $user_group_priority -Force

        if ($PSCmdlet.ShouldProcess($_tacacs.address, 'Configure Tacacs Server')) {
            Invoke-ArubaCXRestMethod -method "PUT" -body $_tacacs -uri $uri -connection $connection
        }

        Get-ArubaCXTacacsServer -address $address -port $port -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXTacacsServer {

    <#
        .SYNOPSIS
        Remove a tacacs server on Aruba CX Switch
        .DESCRIPTION
        Remove a tacacs server on Aruba CX Switch
        .EXAMPLE
        $ts = Get-ArubaCXArubaCXTacacsServer -address 192.2.0.1 -port 49
        PS C:\>$ts | Remove-ArubaCXTacacsServer
        Remove tacacs server with address 192.0.2.1 and port 49
        .EXAMPLE
        Remove-ArubaCXTacacsServer -address 192.2.0.1 -confirm:$false -vrf default
        Remove tacacs server 192.0.2.1 on default vrf with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [string]$address,
        [Parameter (Mandatory = $true, ParameterSetName = "address")]
        [int]$port,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXTacacsServer $_ })]
        [psobject]$ts,
        [Parameter(Mandatory = $false, ParameterSetName = "address")]
        [string]$vrf = "default",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get address, port and vrf from tacacs server ts object
        if ($ts) {
            $address = $ts.address
            $port = $ts.tcp_port
        }

        $uri = "system/vrfs/${vrf}/tacacs_servers/${address},${port}"

        if ($PSCmdlet.ShouldProcess("Tacacs Server (VRF: ${vrf})", "Remove ${address},${port}")) {
            Write-Progress -activity "Remove Tacacs Server"
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Tacacs Server" -completed
        }
    }

    End {
    }
} 