#
# Copyright 2022, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCXFirmware {

    <#
        .SYNOPSIS
        Get Aruba CX firmware

        .DESCRIPTION
        Get all informations about Aruba CX firmware

        .EXAMPLE
        Get-ArubaCXFirmware

        Get all informations about Aruba CX firmware, first image an secondary image

        .EXAMPLE
        Get-ArubaCXFirmware -status

        Get status (date, reason, status) about Aruba CX firmware.
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$status,
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
        #don't have depth, selector or attributes...
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "firmware"

        if ( $PsBoundParameters.ContainsKey('status') ) {
            $uri += "/status"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}