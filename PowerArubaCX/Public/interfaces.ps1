#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXinterfaces {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Interfacess

      .DESCRIPTION
      Get list of all Aruba CX Interfaces (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXIntefarces

      Get list of all interface (lag/port/vlan)

    #>

    Begin {
    }

    Process {

        $uri = "rest/v1/system/interfaces"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET'
        $response
    }

    End {
    }
}