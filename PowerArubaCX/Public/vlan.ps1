function Get-ArubaCXVlan {

    <#
        .SYNOPSIS
        Get list of all Aruba CX Vlan

        .DESCRIPTION
        Get list of all Aruba CX Vlan (name, description, vsx_sync...)

        .EXAMPLE
        Get-ArubaCXVlan

        Get list of all vlan (name, description, vsx_sync...)
    #>
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
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
        [PSObject]$connection = $DefaultArubaSWConnection
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

        $uri = "system/vlans"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}