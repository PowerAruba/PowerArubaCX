#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXRadiusServerGroup {

    <#
        .SYNOPSIS
        Add Aruba CX RADIUS Server Group

        .DESCRIPTION
        Add RADIUS Server Group (group_name, group_type)

        .EXAMPLE
        Add-ArubaCXRadiusServerGroup -group_name PowerArubaCX

        Add RADIUS Server Group with name PowerArubaCX

        .EXAMPLE
        Add-ArubaCXRadiusServerGroup -group_name PowerArubaCX -group_type radius

        Add RADIUS Server Group with name PowerArubaCX and group type radius
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$group_name,
        [Parameter (Mandatory = $false)]
        [ValidateSet('radius','tacacs')]
        [string]$group_type = "tacacs",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/aaa_server_groups"

        $_radius_group = new-Object -TypeName PSObject

        $_radius_group | add-member -name "group_name" -membertype NoteProperty -Value $group_name

        $_radius_group | add-member -name "group_type" -membertype NoteProperty -Value $group_type

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_radius_group -connection $connection
        $response

        Get-ArubaCXRadiusServerGroup -group_name $group_name -connection $connection

    }

    End {
    }
}

function Get-ArubaCXRadiusServerGroup {

    <#
        .SYNOPSIS
        Get list of RADIUS Server Group configured

        .DESCRIPTION
        Get list of RADIUS Server Group configured (group_type, group_name ...)

        .EXAMPLE
        Get-ArubaCXRadiusServerGroup

        Get list of RADIUS Server Group configured (group_type, group_name ...)

        .EXAMPLE
        Get-ArubaCXRadiusServerGroup -group_name RADIUS

        Get RADIUS Server Group with name RADIUS
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [String]$group_name,
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

        if ($PsBoundParameters.ContainsKey('group_name')) {
            $uri = "system/aaa_server_groups/${group_name}"
        }
        else {
            $uri = "system/aaa_server_groups"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        $response

    }

    End {
    }
}

function Set-ArubaCXRadiusServerGroup {

    <#
        .SYNOPSIS
        Configure RADIUS Server Group ArubaCX Switch

        .DESCRIPTION
        Configure RADIUS Server Group (Group type)

        .EXAMPLE
        Get-ArubaCXRadiusServerGroup -group_name PowerArubaCX | Set-ArubaCXRadiusServerGroup -group_type radius

        Configure radius as group type on RADIUS Server Group
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXRadiusServerGroup $_ })]
        [psobject]$radius_group,
        [Parameter (Mandatory = $false, ParameterSetName = "Name")]
        [String]$group_name,
        [Parameter (Mandatory = $true)]
        [ValidateSet('radius','tacacs')]
        [String]$group_type,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $_radius_group = @{ }

        if ($radius_group) {
            $group_name = $radius_group.group_name
        }

        $uri = "system/aaa_server_groups/${group_name}"

        $_radius_group = Get-ArubaCXRadiusServerGroup -group_name $group_name -selector writable

        $_radius_group.group_type = $group_type

        if ($PSCmdlet.ShouldProcess($_radius_group.group_name, 'Configure RADIUS Server Group')) {
            Invoke-ArubaCXRestMethod -method "PUT" -body $_radius_group -uri $uri -connection $connection
        }

        Get-ArubaCXRadiusServerGroup -group_name $group_name -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXRadiusServerGroup {

    <#
        .SYNOPSIS
        Remove a RADIUS Server Group on Aruba CX Switch

        .DESCRIPTION
        Remove a RADIUS Server Group on Aruba CX Switch

        .EXAMPLE
        $rsg = Get-ArubaCXArubaCXRadiusServerGroup -group_name PowerArubaCX
        PS C:\>$rsg | Remove-ArubaCXRadiusServerGroup

        Remove RADIUS Server Group with name PowerArubaCX

        .EXAMPLE
        Remove-ArubaCXRadiusServerGroup -group_name PowerArubaCX -confirm:$false
        Remove RADIUS Server Group PowerArubaCX with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "Name")]
        [string]$group_name,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXRadiusServerGroup $_ })]
        [psobject]$rsg,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        if ($rsg) {
            $group_name = $rsg.group_name
        }

        $uri = "system/aaa_server_groups/${group_name}"

        if ($PSCmdlet.ShouldProcess("RADIUS Server Group)", "Remove ${group_name}")) {
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}