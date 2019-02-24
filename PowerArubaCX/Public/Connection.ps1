#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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
      Connect-ArubaCX -Server 192.0.2.1 -SkipCertificateCheck

      Connect to an ArubaCX Switch using HTTPS (without check certificate validation) with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      $cred = get-credential
      PS C:\>Connect-ArubaCX -Server 192.0.2.1 -credential $cred

      Connect to a ArubaCX Switch with IP 192.0.2.1 and passing (Get-)credential

      .EXAMPLE
      $mysecpassword = ConvertTo-SecureString aruba -AsPlainText -Force
      PS C:\>Connect-ArubaCX -Server 192.0.2.1 -Username admin -Password $mysecpassword

      Connect to a ArubaCX Switch with IP 192.0.2.1 using Username and Password
  #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials,
        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false
    )

    Begin {
    }

    Process {


        $connection = @{server = ""; session = ""; cookie = ""}

        #If there is a password (and a user), create a credentials
        if ($Password) {
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
        }
        #Not Credentials (and no password)
        if ($null -eq $Credentials) {
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your ArubaCX Switch'
        }

        #Allow untrusted SSL certificat and enable TLS 1.2 (needed by ArubaCX)
        Set-ArubaCXCipherSSL
        if ( $SkipCertificateCheck ) {
            Set-ArubaCXuntrustedSSL
        }
        $postParams = @{username = $Credentials.username; password = $Credentials.GetNetworkCredential().Password}
        $url = "https://${Server}/rest/v1/login"
        try {
            $response = Invoke-RestMethod $url -Method POST -Body $postParams -SessionVariable arubacx
        }
        catch {
            $_
            throw "Unable to connect"
        }

        $connection.server = $server
        $connection.cookie = $cookie
        $connection.session = $arubacx

        set-variable -name DefaultArubaCXConnection -value $connection -scope Global

        $connection
    }

    End {
    }
}

function Disconnect-ArubaCX {

    <#
        .SYNOPSIS
        Disconnect to a ArubaCX Switches

        .DESCRIPTION
        Disconnect the connection on ArubaCX Switchs

        .EXAMPLE
        Disconnect-ArubaCX

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaCX -noconfirm

        Disconnect the connection with no confirmation

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $url = "rest/v1/logout"

        if ( -not ( $Noconfirm )) {
            $message = "Remove ArubaCX Switch connection."
            $question = "Proceed with removal of ArubaCX Switch connection ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove ArubaCX SW connection"
            $null = invoke-ArubaCXRestMethod -method "POST" -url $url
            write-progress -activity "Remove ArubaCX SW connection" -completed
            if (Get-Variable -Name DefaultArubaCXConnection -scope global ) {
                Remove-Variable -name DefaultArubaCXConnection -scope global
            }
        }

    }

    End {
    }
}
