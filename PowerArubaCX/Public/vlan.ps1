function Get-ArubaCXvlan {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Vlan

      .DESCRIPTION
      Get list of all Aruba CX Vlan (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXvlan

        Get list of all vlan, lag,with name IP and more

    #>
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
        [Int]$depth,
        [Parameter(Mandatory = $false)]
        [ValidateSet("configuration", "status", "statistics")]
        [String]$selector,
        [Parameter(Mandatory = $false)]
        [String[]]$attributes
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

        $uri = "system/vlans"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' @invokeParams
        $response
    }

    End {
    }
}