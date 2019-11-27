function Get-ArubaCXvlan {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Vlan

      .DESCRIPTION
      Get list of all Aruba CX Vlan (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXvlan

        1                           20
        -                           --
        /rest/v10.04/system/vlans/1 /rest/v10.04/system/vlans/20
      
        Get list of all vlan 

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

        $uri = "rest/v10.04/system/vlans"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' @invokeParams
        $response
    }

    End {
    }
}