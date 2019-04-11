#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Get-ArubaCXPorts {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Ports

      .DESCRIPTION
      Get list of all Aruba CX Ports (name, Mode, vlan, description....)

      .EXAMPLE
      Get-ArubaCXPorts

      Get list of all ports

    #>

    Begin {
    }

    Process {

        $response = Invoke-ArubaCXRestMethod -uri 'rest/v1/system/ports' -method 'GET'
        $response
    }

    End {
    }
}