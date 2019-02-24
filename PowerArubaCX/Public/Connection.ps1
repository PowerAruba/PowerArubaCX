#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaCX {

  <#
      .SYNOPSIS
      Connect to a ArubaCX Switches

      .DESCRIPTION
      Connect to a ArubaCX Switches
      .EXAMPLE
      Connect-ArubaCX -Server 192.0.2.1

      Connect to a ArubaCX Switch with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      $cred = get-credential
      Connect-ArubaCX -Server 192.0.2.1 -credential $cred

      Connect to a ArubaCX Switch with IP 192.0.2.1 and passing (Get-)credential

      .EXAMPLE
      $mysecpassword = ConvertTo-SecureString aruba -AsPlainText -Force
      Connect-ArubaCX -Server 192.0.2.1 -Username admin -Password $mysecpassword

      Connect to a ArubaCX Switch with IP 192.0.2.1 using Username and Password
  #>

    Param(
        [Parameter(Mandatory = $true, position=1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials
    )

    Begin {
    }

    Process {


        $connection = @{server="";session="";cookie=""}

        #If there is a password (and a user), create a credentials
        if ($Password) {
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
        }
        #Not Credentials (and no password)
        if ($Credentials -eq $null)
        {
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your ArubaCX Switch'
        }

        #Allow untrusted SSL certificat and enable TLS 1.2 (needed by ArubaCX)
        Set-ArubaCXuntrustedSSL
        Set-ArubaCXCipherSSL

        $postParams = @{username=$Credentials.username;password=$Credentials.GetNetworkCredential().Password}
        $url = "https://${Server}/rest/v1/login"
        try {
            $response = Invoke-WebRequest $url -Method POST -Body $postParams -SessionVariable arubacx
        }
        catch {
            Show-ArubaCXException $_
            throw "Unable to connect"
        }
        $response.headers

        $connection.server = $server
        $connection.cookie = $cookie
        $connection.session = $arubacx

        set-variable -name DefaultArubaCXConnection -value $connection -scope Global

    }

    End {
    }
}