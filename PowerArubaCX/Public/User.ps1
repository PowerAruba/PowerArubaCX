function Get-ArubaCXUser {

    <#
      .SYNOPSIS
      Get Aruba CX user

      .DESCRIPTION
      Get all informations about Aruba CX Users

      .EXAMPLE
      Get-ArubaCXusers

        admin
        -----
        /rest/v10.04/system/users/admin
    #>
    Param(
    )

    Begin {
    }

    Process {

        $uri = "rest/v10.04/system/users"


        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET'
        $response
    }

    End {
    }
}