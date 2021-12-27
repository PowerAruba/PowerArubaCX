#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCXAAAServerGroup {

    <#
        .SYNOPSIS
        Add Aruba CX AAA Server Group

        .DESCRIPTION
        Add AAA Server Group (group_name, group_type)

        .EXAMPLE
        Add-ArubaCXAAAServerGroup -group_name PowerArubaCX

        Add AAA Server Group with name PowerArubaCX

        .EXAMPLE
        Add-ArubaCXAAAServerGroup -group_name PowerArubaCX -group_type radius

        Add AAA Server Group with name PowerArubaCX and group type radius
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

        Get-ArubaCXAAAServerGroup -group_name $group_name -connection $connection

    }

    End {
    }
}

function Get-ArubaCXAAAServerGroup {

    <#
        .SYNOPSIS
        Get list of AAA Server Group configured

        .DESCRIPTION
        Get list of AAA Server Group configured (group_type, group_name ...)

        .EXAMPLE
        Get-ArubaCXAAAServerGroup

        Get list of AAA Server Group configured (group_type, group_name ...)

        .EXAMPLE
        Get-ArubaCXAAAServerGroup -group_name RADIUS

        Get AAA Server Group with name RADIUS
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

function Set-ArubaCXAAAServerGroup {

    <#
        .SYNOPSIS
        Configure AAA Server Group ArubaCX Switch

        .DESCRIPTION
        Configure AAA Server Group (Group type)

        .EXAMPLE
        Get-ArubaCXAAAServerGroup -group_name PowerArubaCX | Set-ArubaCXAAAServerGroup -group_type radius

        Configure radius as group type on AAA Server Group
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXAAAServerGroup $_ })]
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

        $_radius_group = Get-ArubaCXAAAServerGroup -group_name $group_name -selector writable

        $_radius_group.group_type = $group_type

        if ($PSCmdlet.ShouldProcess($_radius_group.group_name, 'Configure AAA Server Group')) {
            Invoke-ArubaCXRestMethod -method "PUT" -body $_radius_group -uri $uri -connection $connection
        }

        Get-ArubaCXAAAServerGroup -group_name $group_name -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXAAAServerGroup {

    <#
        .SYNOPSIS
        Remove a AAA Server Group on Aruba CX Switch

        .DESCRIPTION
        Remove a AAA Server Group on Aruba CX Switch

        .EXAMPLE
        $rsg = Get-ArubaCXArubaCXAAAServerGroup -group_name PowerArubaCX
        PS C:\>$rsg | Remove-ArubaCXAAAServerGroup

        Remove AAA Server Group with name PowerArubaCX

        .EXAMPLE
        Remove-ArubaCXAAAServerGroup -group_name PowerArubaCX -confirm:$false
        Remove AAA Server Group PowerArubaCX with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "Name")]
        [string]$group_name,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ID")]
        [ValidateScript( { Confirm-ArubaCXAAAServerGroup $_ })]
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

        if ($PSCmdlet.ShouldProcess("AAA Server Group)", "Remove ${group_name}")) {
            Invoke-ArubaCXRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}