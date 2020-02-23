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
       rest/vX is automatically add to uri, use -noapiversion for remove

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "system"

      Invoke-RestMethod with ArubaCX connection for get rest/vX/system

      .EXAMPLE
      Invoke-ArubaCXRestMethod "system"

      Invoke-RestMethod with ArubaCX connection for get rest/vX/system uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "post" -uri "system" -body $body

      Invoke-RestMethod with ArubaCX connection for post rest/vX/system uri with $body payload

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "system" -depth 1 -selector configuration

      Invoke-RestMethod with ArubaCX connection for get rest/vX/system with depth 1 and select only configuration

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "system" -attributes hostname, dns_servers

      Invoke-RestMethod with ArubaCX connection for get rest/vX/system with display only attributes hostname and dns_servers

      .EXAMPLE
      Invoke-ArubaCXRestMethod -method "get" -uri "rest/v10.04/system" -noapiversion

      Invoke-RestMethod with ArubaCX connection for get rest/v10.04/system (need to specify full uri with rest/vX)
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
        [ValidateRange(1, 4)]
        [Int]$depth,
        [Parameter(Mandatory = $false, ParameterSetName = "selector")]
        [ValidateSet("configuration", "status", "statistics", "writable")]
        [String]$selector,
        [Parameter(Mandatory = $false, ParameterSetName = "attributes")]
        [String[]]$attributes,
        [Parameter(Mandatory = $false)]
        [switch]$vsx_peer,
        [Parameter(Mandatory = $false)]
        [switch]$noapiversion,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    Begin {
    }

    Process {

        if ($null -eq $connection) {
            if ($null -eq $DefaultArubaCXConnection) {
                Throw "Not Connected. Connect to the Switch with Connect-ArubaCX"
            }
            $connection = $DefaultArubaCXConnection
        }

        $Server = $connection.Server
        $port = $connection.port
        $headers = $connection.headers
        $invokeParams = $connection.invokeParams
        $sessionvariable = $connection.session
        $rest = 'rest/' + $connection.version + '/'

        #Remove rest/version on uri
        if ($noapiversion) {
            $rest = ""
        }

        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            #Add /vsx-peer/ before uri
            $fullurl = "https://${Server}:${port}/vsx-peer/${rest}${uri}"
        }
        else {
            $fullurl = "https://${Server}:${port}/${rest}${uri}"
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

        try {
            if ($body) {

                Write-Verbose ($body | ConvertTo-Json)

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