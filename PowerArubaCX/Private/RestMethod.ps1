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

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "rest/v1/system" -depth 1 -selector configuration

      Invoke-RestMethod with ArubaCX connection for get rest/v1/system with depth 1 and select only configuration

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "rest/v1/system" -attributes hostname, dns_servers

      Invoke-RestMethod with ArubaCX connection for get rest/v1/system with display only attributes hostname and dns_servers
    #>

    [CmdletBinding(DefaultParametersetname = "default")]
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method = "get",
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
        [Int]$depth,
        [Parameter(Mandatory = $false, ParameterSetName = "selector")]
        [ValidateSet("configuration", "status", "statistics")]
        [String]$selector,
        [Parameter(Mandatory = $false, ParameterSetName = "attributes")]
        [String[]]$attributes,
        [Parameter(Mandatory = $false)]
        [switch]$vsx_peer
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCXConnection}.Server
        $headers = ${DefaultArubaCXConnection}.headers
        $invokeParams = ${DefaultArubaCXConnection}.invokeParams

        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            #Add /vsx-peer/ before uri
            $fullurl = "https://${Server}/vsx-peer/${uri}"
        }
        else {
            $fullurl = "https://${Server}/${uri}"
        }

        if ($fullurl -NotMatch "\?") {
            $fullurl += "?"
        }

        if ( $PsBoundParameters.ContainsKey('depth') ) {
            $fullurl += "&depth=$depth"
        }
        if ( $PsBoundParameters.ContainsKey('selector') ) {
            $fullurl += "&selector=$selector"
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $attributes = $attributes -Join ','
            $fullurl += "&attributes=$attributes"
        }

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