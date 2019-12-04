function Get-ArubaCXfirmware {

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
    )

    Begin {
    }

    Process {

        $uri = "firmware"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET'
        $response
    }

    End {
    }
}