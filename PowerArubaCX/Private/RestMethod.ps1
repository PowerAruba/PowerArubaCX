#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCXRestMethod {

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCXConnection}.Server
        $headers = ${DefaultArubaCXConnection}.headers

        $fullurl = "https://${Server}/${uri}"

        $sessionvariable = $DefaultArubaCXConnection.session

        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers -WebSession $sessionvariable
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers -WebSession $sessionvariable
            }
        }

        catch {
            Show-ArubaCXException $_
            throw "Unable to use ArubaCX API"
        }
        $response

    }

}