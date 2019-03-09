#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCXRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with ArubaCX connection (internal) variable

      .DESCRIPTION
       Invoke RestMethod with ArubaCX connection variable (token, csrf..)

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "rest/v1/system"

      Invoke-RestMethod with ArubaCX connection for get rest/v1/system

      .EXAMPLE
      Invoke-ArubaCXRestMethod "rest/v1/system"

      Invoke-RestMethod with ArubaCX connection for get rest/v1/system uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "post" -uri "rest/v1/system" -body $body

      Invoke-RestMethod with ArubaCX connection for post rest/v1/system uri with $body payload
    #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method = "get",
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCXConnection}.Server
        $headers = ${DefaultArubaCXConnection}.headers
        $invokeParams = ${DefaultArubaCXConnection}.invokeParams

        $fullurl = "https://${Server}/${uri}"

        $sessionvariable = $DefaultArubaCXConnection.session

        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers -WebSession $sessionvariable @invokeParams
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers -WebSession $sessionvariable @invokeParams
            }
        }

        catch {
            Show-ArubaCXException $_
            throw "Unable to use ArubaCX API"
        }
        $response

    }

}