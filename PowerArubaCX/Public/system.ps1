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

    Begin {
    }

    Process {

        $uri = "rest/v1/system"

        $response = invoke-ArubaCXRestMethod -method "GET" -uri $uri
        $response
    }

    End {
    }
}