function Get-ArubaCXFirmware {

    <#
        .SYNOPSIS
        Get Aruba CX firmware

        .DESCRIPTION
        Get all informations about Aruba CX firmware

        .EXAMPLE
        Get-ArubaCXfirmware

        Get all informations about Aruba CX firmware, first image an secondary image
    #>

    Param(
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
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "firmware"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams
        $response
    }

    End {
    }
}