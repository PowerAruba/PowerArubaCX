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
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "system"

        $response = invoke-ArubaCXRestMethod -method "GET" -uri $uri -connection $connection @invokeParams
        $response
    }

    End {
    }
}

function Set-ArubaCXSystem {

    <#
        .SYNOPSIS
        Configure Vlan info on ArubaOS Switch (Provision)

        .DESCRIPTION
        Configure vlan info (Id, Name, Voice, Snooping...)

        .EXAMPLE
        $vlan = Get-ArubaSWVlans -id 85
        PS C:\>$vlan | Set-ArubaSWVlans -Name PowerArubaSW -is_voice_enabled -is_jumbo_enabled:$false

        Configure vlan id 85 with name PowerArubaSW and enable voice vlan and disable jumbo
        .EXAMPLE
        Set-ArubaSWVlans -id 85 -Name PowerArubaSW2 -is_voice_enabled -is_dsnoop_enabled:$false

        Configure vlan id 85 with name PowerArubaSW2 and enable voice vlan and disable dsnoop

    #>

    Param(
        [Parameter (Mandatory = $false)]
        [string]$hostname
    )

    Begin {
    }

    Process {

        $uri = "rest/v1/system"

        $_system = new-Object -TypeName PSObject


        if ( $PsBoundParameters.ContainsKey('hostname') ) {
            $_system | add-member -name "hostname" -membertype NoteProperty -Value $name
        }

        $response = invoke-ArubaCXRestMethod -method "PUT" -body $_system -uri $uri
        $response
    }

    End {
    }
}