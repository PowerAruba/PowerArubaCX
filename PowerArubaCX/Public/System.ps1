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
        Configure System info on ArubaCX Switch

        .DESCRIPTION
        Configure System info (Hostname, Banner...)

        .EXAMPLE
        Set-ArubaCXSystem -hostname "My ArubaCX Switch"

        Configure hostname

        .EXAMPLE
        Set-ArubaCXSystem -banner "Welcome on PowerArubaCX Switch"

        Configure Banner

        .EXAMPLE
        Set-ArubaCXSystem -timezone Europe/Paris

        Configure Timezone

        .EXAMPLE
        Set-ArubaCXSystem -contact Power -description Aruba -location CX

        Configure System Contact, Description and Location

        .EXAMPLE
        $system = Get-ArubaCXSystem -selector writable
        PS >$system.usb_disable = $true
        PS > $system | Set-ArubaCXSystem -use_pipeline

        Configure some system variable (usb_disable) no available on parameter using pipeline (can be only with selector equal writable)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $false, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCXSystem $_ })]
        [psobject]$system,
        [Parameter (Mandatory = $false)]
        [string]$hostname,
        [Parameter (Mandatory = $false)]
        [string]$banner,
        [Parameter (Mandatory = $false)]
        #add Check of timezone ? very long list..
        [string]$timezone,
        [Parameter (Mandatory = $false)]
        [string]$contact,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [string]$location,
        [Parameter (Mandatory = $false)]
        [switch]$use_pipeline,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )


    Begin {
    }

    Process {

        $uri = "system"

        if ($use_pipeline) {
            $_system = $system
        }
        else {
            $_system = Get-ArubaCXSystem -selector writable -connection $connection
        }

        if ( $PsBoundParameters.ContainsKey('hostname') ) {
            $_system.hostname = $hostname
        }
        if ( $PsBoundParameters.ContainsKey('banner') ) {
            $_system.other_config.banner = $banner
        }
        if ( $PsBoundParameters.ContainsKey('timezone') ) {
            $_system.timezone = $timezone
        }
        if ( $PsBoundParameters.ContainsKey('contact') ) {
            if ($_system.other_config.system_contact) {
                $_system.other_config.system_contact = $contact
            }
            else {
                $_system.other_config | Add-member -name "system_contact" -membertype NoteProperty -Value $contact
            }
        }
        if ( $PsBoundParameters.ContainsKey('description') ) {
            if ($_system.other_config.system_description) {
                $_system.other_config.system_description = $description
            }
            else {
                $_system.other_config | Add-member -name "system_description" -membertype NoteProperty -Value $description
            }
        }
        if ( $PsBoundParameters.ContainsKey('location') ) {
            if ($_system.other_config.system_location) {
                $_system.other_config.system_location = $location
            }
            else {
                $_system.other_config | Add-member -name "system_location" -membertype NoteProperty -Value $location
            }
        }

        if ($PSCmdlet.ShouldProcess($_system.hostname, 'Configure System Settings')) {
            Invoke-ArubaCXRestMethod -method "PUT" -body $_system -uri $uri -connection $connection
        }

        Get-ArubaCXSystem -connection $connection
    }

    End {
    }
}