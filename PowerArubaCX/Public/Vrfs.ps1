#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Add-ArubaCXVrfs {

    <#
        .SYNOPSIS
        Add Aruba CX Vrf

        .DESCRIPTION
        Add Vrf (name, rd, https, ssh, snmp)

        .EXAMPLE
        Add-ArubaCXVrfs -name MyVRF

        Add Vrf named MyVRF

        .EXAMPLE
        Add-ArubaCXVrfs -name MyVRF -rd 65001:1

        Add Vrf named myVRF with RD 65001:1

        .EXAMPLE
        Add-ArubaCXVrfs -name myVRF -ssh_enable -snmp_enable -https_server

        Add Vrf named MyVRF with ssh, snmp and https enable
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$rd,
        [Parameter (Mandatory = $false)]
        [switch]$https_server,
        [Parameter (Mandatory = $false)]
        [switch]$snmp_enable,
        [Parameter (Mandatory = $false)]
        [switch]$ssh_enable,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/vrfs"

        $_vrf = new-Object -TypeName PSObject

        $_vrf | add-member -name "name" -membertype NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('rd') ) {
            $_vrf | add-member -name "rd" -membertype NoteProperty -Value $rd
        }

        if ( $PsBoundParameters.ContainsKey('https_server') ) {
            if ($https_server) {
                $_vrf | add-member -name "https_server" -membertype NoteProperty -Value @{"enable" = $True }
            }
            else {
                $_vrf | add-member -name "https_server" -membertype NoteProperty -Value @{ }
            }
        }

        if ( $PsBoundParameters.ContainsKey('snmp_enable') ) {
            if ($snmp_enable) {
                $_vrf | add-member -name "snmp_enable" -membertype NoteProperty -Value $true
            }
            else {
                $_vrf | add-member -name "snmp_enable" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('ssh_enable') ) {
            if ($ssh_enable) {
                $_vrf | add-member -name "ssh_enable" -membertype NoteProperty -Value $true
            }
            else {
                $_vrf | add-member -name "ssh_enable" -membertype NoteProperty -Value $false
            }
        }
        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_vrf -connection $connection
        $response

        Get-ArubaCXVrfs -name $name -connection $connection
    }

    End {
    }
}

function Get-ArubaCXVrfs {

    <#
        .SYNOPSIS
        Get list of all Aruba CX Vrf

        .DESCRIPTION
        Get list of all Aruba CX Vrf (name, rd, https, ssh, snmp)

        .EXAMPLE
        Get-ArubaCXVrfs

        Get list of all Vrf (name, rd, https, ssh, snmp.)

        .EXAMPLE
        Get-ArubaCXVrfs -name MyVrf

        Get Vrf named MyVrf
    #>

    [CmdletBinding(DefaultParametersetname = "Default")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "name", position = "1")]
        [string]$name,
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
            #You need to specify a vrf for use writable selector (it is not possible to use on collections...)
            if ($PSCmdlet.ParameterSetName -eq "Default" -and $selector -eq "writable") {
                Throw "You need to specify a vrf to use writable selector"
            }
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "system/vrfs"

        # you can directly filter by name
        if ( $PsBoundParameters.ContainsKey('name') ) {
            $uri += "/$name"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        #Add id parameter when use writable type selector
        if ( $PsBoundParameters.ContainsKey('selector') -and $selector -eq "writable" ) {
            $response | add-member -name "name" -membertype NoteProperty -Value $name
        }

        $response
    }

    End {
    }
}

function Set-ArubaCXVrfs {

    <#
        .SYNOPSIS
        Configure Aruba CX Vrf

        .DESCRIPTION
        Configure Vrf (name, rd, https, ssh, snmp)

        .EXAMPLE
        Get-ArubaCXVrfs -name MyVrf | Set-ArubaCXVrfs -rd 65001:01

        Configure RD on VRF MyVrf

        .EXAMPLE
        Get-ArubaCXVrfs -name MyVrf | Set-ArubaCXVrfs -https_server -ssh_enable:$false -snmp_enable:$false

        Configure https_server (enable) and ssh/snmp (disable) on VRF MyVrf

        .EXAMPLE
        $vrf = Get-ArubaCXVrfs -name MyVRF -selector writable
        PS> $vrf.ssh_enable = $true
        PS> $vrf | Set-ArubaCXVrfs -use_pipeline

        Configure Vrf myVRF name using pipeline (can be only with selector equal writable)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "name")]
        [string]$name,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vrf")]
        [ValidateScript( { Confirm-ArubaCXVrfs $_ })]
        [psobject]$vrf,
        [Parameter (Mandatory = $false)]
        [string]$rd,
        [Parameter (Mandatory = $false)]
        [switch]$https_server,
        [Parameter (Mandatory = $false)]
        [switch]$snmp_enable,
        [Parameter (Mandatory = $false)]
        [switch]$ssh_enable,
        [Parameter (Mandatory = $false)]
        [switch]$use_pipeline,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get vrf id from vrf ps object
        if ($vrf) {
            $name = $vrf.name
        }

        $uri = "system/vrfs/${name}"

        if ($use_pipeline) {
            $_vrf = $vrf
        }
        else {
            $_vrf = Get-ArubaCXVrfs -name $name -selector writable -connection $connection
        }

        #Remove name from vrf (can not be modified)
        $_vrf.psobject.Properties.remove("name")

        if ( $PsBoundParameters.ContainsKey('rd') ) {
            $_vrf.rd = $rd
        }

        if ( $PsBoundParameters.ContainsKey('https_server') ) {
            if ($https_server) {
                $_vrf.https_server = @{"enable" = $true }
            }
            else {
                $_vrf.https_server = @{ }
            }
        }

        if ( $PsBoundParameters.ContainsKey('snmp_enable') ) {
            if ($snmp_enable) {
                $_vrf.snmp_enable = $true
            }
            else {
                $_vrf.snmp_enable = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('ssh_enable') ) {
            if ($ssh_enable) {
                $_vrf.ssh_enable = $true
            }
            else {
                $_vrf.ssh_enable = $false
            }
        }

        if ($PSCmdlet.ShouldProcess($id, 'Configure Vrf Settings')) {
            $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_vrf -connection $connection
            $response
        }

        Get-ArubaCXVrfs -name $name -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXVrfs {

    <#
        .SYNOPSIS
        Remove a Vrf on Aruba CX Switch

        .DESCRIPTION
        Remove a Vrf on Aruba CX Switch

        .EXAMPLE
        $vrf = Get-ArubaCXVrfs -name MyVrf
        PS C:\>$vrf | Remove-ArubaCXVrfs

        Remove Vrf named MyVrf

        .EXAMPLE
        Remove-ArubaCXVrfs -name MyVrf -confirm:$false

        Remove Vrf named MyVrf with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "name")]
        [string]$name,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vrf")]
        [ValidateScript( { Confirm-ArubaCXVrfs $_ })]
        [psobject]$vrf,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        #get vrf id from vrf ps object
        if ($vrf) {
            $name = $vrf.name
        }

        $uri = "system/vrfs/${name}"

        if ($PSCmdlet.ShouldProcess("Vrf", "Remove Vrf ${name}")) {
            Write-Progress -activity "Remove Vrf"
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Vrf" -completed
        }
    }

    End {
    }
}