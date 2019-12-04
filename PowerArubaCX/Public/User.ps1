function Get-ArubaCXUser {

    <#
      .SYNOPSIS
      Get Aruba CX user

      .DESCRIPTION
      Get all informations about Aruba CX Users

      .EXAMPLE
      Get-ArubaCXusers

      List all users in ArubaCX

    #>
    Param(
    )

    Begin {
    }

    Process {

        $uri = "system/users"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET'
        $response
    }

    End {
    }
}