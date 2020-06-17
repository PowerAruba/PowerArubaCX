function Get-ArubaCXConfiguration {

    <#
        .SYNOPSIS
        Get Aruba CX running or startup-configuration

        .DESCRIPTION
        Get the startup-config or running-config and copy it to a remote location

        .EXAMPLE
        Get-ArubaCXConfiguration -local running -remote sftp://192.0.2.1/backups_switchs/arubacx/ -type cli -vrf mgmt

        Get the running-config and copy it to the remote location 192.0.2.1/backups_switchs/arubacx using sftp, in cli format via thr mgmt vrf
    #>

    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("running","startup")]
        [string]$local,
        [Parameter(Mandatory = $false)]
        [string]$remote,
        [Parameter(Mandatory = $false)]
        [ValidateSet("cli","json")]
        [string]$type,
        [Parameter(Mandatory = $false)]
        [string]$vrf,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $remote = $remote.Replace(":","%3A")
        $remote = $remote.Replace("/","%2F")

        $uri = "fullconfigs/${local}-config/?to=${remote}&type=${type}&vrf=${vrf}"

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection 
        $response
    }

    End {
    }
}