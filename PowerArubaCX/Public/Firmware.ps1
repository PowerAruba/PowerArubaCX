function Get-ArubaCXfirmware {

    <#
      .SYNOPSIS
      Get Aruba CX firmware

      .DESCRIPTION
      Get all informations about Aruba CX firmware

      .EXAMPLE
      Get-ArubaCXfirmware

        current_version   : Virtual.10.04.0001
        primary_version   :
        secondary_version :
        default_image     :
        booted_image      :

    #>
    Param(
    )

    Begin {
    }

    Process {

        $uri = "rest/v10.04/firmware"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET'
        $response
    }

    End {
    }
}