#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Add-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Add Aruba CX Interfaces (lag, vlan...)

      .DESCRIPTION
      Add Aruba CX Interfaces (lag, vlan... with IP Address, description)

      .EXAMPLE
      Add-ArubaCXInterfaces -vlan_id 23 -description "Add by PowerArubaCX"

      Add interface vlan 23 with a description

      .EXAMPLE
      Add-ArubaCXInterfaces -vlan_id 23 -ip4_address 192.0.2.1 -ip4_mask 24

      Add interface vlan 23 with IPv4 Address 192.0.2.1/24

      .EXAMPLE
      Add-ArubaCXInterfaces -vlan_id 23 -admin down

      Add interface vlan 23 with admin status to down

      .EXAMPLE
      Add-ArubaCXInterfaces -lag_id 2 -admin up -interfaces 1/1/1 -ip4_address 192.0.2.1 -ip4_mask 24

      Add interface lag 2 with admin status to up and interfaces 1/1/1 with IPv4 Address 192.0.2.1/24

      .EXAMPLE
      Add-ArubaCXInterfaces -lag_id 2 -admin up -interfaces 1/1/2, 1/1/3 -routing:$false -vlan_tag 23

      Add interface lag 2 with admin status to up and interfaces 1/1/2 and 1/1/3 with no routing and vlan acces 23

      .EXAMPLE
      Add-ArubaCXInterfaces -loopback 1 -ip4_address 198.51.100.1 -ip4_mask 32

      Add interface loopback 1 with IPv4 Address 198.51.100.1/32 (and admin up)
      #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "vlan")]
        [string]$vlan_id,
        [Parameter (Mandatory = $true, ParameterSetName = "lag")]
        [string]$lag_id,
        [Parameter (Mandatory = $true, ParameterSetName = "loopback")]
        [string]$loopback_id,
        [Parameter(Mandatory = $false)]
        [ValidateSet('up', 'down')]
        [string]$admin,
        [Parameter(Mandatory = $false)]
        [string]$description,
        [Parameter(Mandatory = $false, ParameterSetName = "lag")]
        [switch]$routing,
        [Parameter(Mandatory = $false, ParameterSetName = "lag")]
        [ValidateSet('access', 'native-untagged', 'native-tagged', IgnoreCase = $false)]
        [string]$vlan_mode,
        [Parameter(Mandatory = $false, ParameterSetName = "lag")]
        [ValidateRange(1, 4096)]
        [int]$vlan_tag,
        [Parameter(Mandatory = $false, ParameterSetName = "lag")]
        #[ValidateRange(1, 4096)]
        [int[]]$vlan_trunks,
        [Parameter(Mandatory = $false, ParameterSetName = "lag")]
        [string[]]$interfaces,
        [Parameter(Mandatory = $false)]
        [ipaddress]$ip4_address,
        [Parameter(Mandatory = $false)]
        [ValidateRange(8, 32)]
        [int]$ip4_mask,
        [Parameter(Mandatory = $false)]
        [string]$vrf = "default",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )
    Begin {

    }
    Process {
        $uri = "system/interfaces"

        switch ( $PSCmdlet.ParameterSetName ) {
            "vlan" {
                $name = "vlan" + $vlan_id
                $vlan_tag = $vlan_id
            }
            "lag" {
                $name = "lag" + $lag_id
            }
            "loopback" {
                $name = "loopback" + $loopback_id
            }
        }

        $_interface = New-Object -TypeName PSObject

        $_interface | Add-Member -name "name" -membertype NoteProperty -Value $name

        $_interface | Add-Member -name "type" -membertype NoteProperty -Value $PSCmdlet.ParameterSetName

        if ( $PsBoundParameters.ContainsKey('interfaces') ) {
            $intf = @()
            foreach ($interface in $interfaces) {
                $intf += "/rest/" + $($connection.api_version) + "/system/interfaces/" + ($interface -replace '/', '%2F')
            }
            $_interface | Add-Member -name "interfaces" -membertype NoteProperty -Value $intf
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            switch ( $PSCmdlet.ParameterSetName ) {
                "vlan" {
                    $user_config = New-Object -TypeName PSObject
                    $user_config | Add-member -name "admin" -membertype NoteProperty -Value $admin
                    $_interface | Add-Member -name "user_config" -membertype NoteProperty -Value $user_config
                }
                "lag" {
                    $_interface | Add-Member -name "admin" -membertype NoteProperty -Value $admin
                }
                "loopback" {
                    $_interface | Add-Member -name "admin" -membertype NoteProperty -Value $admin
                }
            }
        }

        $vrf = "/rest/" + $($connection.api_version) + "/system/vrfs/" + $vrf
        $_interface | Add-Member -name "vrf" -membertype NoteProperty -Value $vrf

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_interface | Add-Member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('routing') ) {
            if ($routing) {
                $_interface | Add-Member -name "routing" -membertype NoteProperty -Value $true
            }
            else {
                $_interface | Add-Member -name "routing" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vlan_mode') ) {
            $_interface | Add-Member -name "vlan_mode" -membertype NoteProperty -Value $vlan_mode
        }

        if ($vlan_tag) {
            $_interface | Add-Member -name "vlan_tag" -membertype NoteProperty -Value ("/rest/" + $($connection.api_version) + "/system/vlans/" + $vlan_tag)
        }

        if ( $PsBoundParameters.ContainsKey('vlan_trunks') ) {
            $trunks = @()
            foreach ($trunk in $vlan_trunks) {
                $trunks += "/rest/" + $($connection.api_version) + "/system/vlans/" + $trunk
            }
            $_interface | Add-Member -name "vlan_trunks" -membertype NoteProperty -Value $trunks
        }

        if ( $PsBoundParameters.ContainsKey('ip4_address') ) {
            if ($ip4_address -eq $null ) {
                $_interface | Add-Member -name "ip4_address" -membertype NoteProperty -Value $null
            }
            else {
                if ($ip4_mask -eq "0" ) {
                    Throw "You need to set ip4_mask when use ipv4_address"
                } if ($_interface.routing -eq $false) {
                    Throw "You need to enable routing mode for use ipv4_address"
                } if ( -not ($ip4_address.AddressFamily -eq "InterNetwork" )) {
                    Throw "You need to specify a IPv4 Address"
                }
                $_interface | Add-Member -name "ip4_address" -membertype NoteProperty -Value ($ip4_address.ToString() + "/" + $ip4_mask)
            }
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'POST' -body $_interface -connection $connection
        $response
        Get-ArubaCXInterfaces $name -connection $connection
    }
    End {

    }
}
function Add-ArubaCXInterfacesVlanTrunks {

    <#
      .SYNOPSIS
      Add vlan on an interface

      .DESCRIPTION
      Add vlan (tagged) on an interface
      The interface need already to be on tagged mode

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks 44

      Add vlan 44 to vlan trunks on interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks 44, 45

      Add vlan 44 and 45 to vlan trunks on interface 1/1/1

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCXInterfaces $_ })]
        [psobject]$int,
        [Parameter(Mandatory = $true)]
        #[ValidateRange(1, 4096)]
        [int[]]$vlan_trunks,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"

        #get interface name from int ps object
        $interface = $int.name

        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        $_interface = Get-ArubaCXInterfaces $interface -selector writable -connection $connection

        #Remove name from vlan (can not be modified)
        $_interface.psobject.Properties.remove("name")

        if ($_interface.routing -eq $true) {
            Throw "You need to disable routing mode for use vlan_trunks"
        }

        if (-not ($_interface.vlan_mode -eq "native-untagged" -or $_interface.vlan_mode -eq "native-tagged")) {
            Throw "You need to use native-(un)tagged vlan mode"
        }

        #get list of existant vlan
        $vlans = $_interface.vlan_trunks
        if ($vlans) {
            foreach ($v in $vlans.psobject.Properties.Name) {
                $vlan_trunks += $v
            }
        }

        $trunks = @()
        #Add new vlan
        foreach ($trunk in $vlan_trunks) {
            $trunks += "/rest/" + $($connection.api_version) + "/system/vlans/" + $trunk
        }
        $_interface.vlan_trunks = $trunks

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_interface -connection $connection
        $response
        Get-ArubaCXInterfaces $interface -connection $connection
    }

    End {
    }
}
function Add-ArubaCXInterfacesLagInterfaces {

    <#
      .SYNOPSIS
      Add interfaces (members) on an interface LAG

      .DESCRIPTION
      Add interfaces (members) on an interface LAG

      .EXAMPLE
      Get-ArubaCXInterfaces -interface lag 2 | Add-ArubaCXInterfacesLagInterfaces -interfaces 1/1/1

      Add interface 1/1/1 on lag 2

      .EXAMPLE
      Get-ArubaCXInterfaces -interface lag 2 | Add-ArubaCXInterfacesLagInterfaces -interfaces 1/1/1, 1/1/2

      Add interfaces 1/1/1 and 1/1/2 on lag 2

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCXInterfaces $_ })]
        [psobject]$int,
        [Parameter(Mandatory = $true)]
        #[ValidateRange(1, 4096)]
        [string[]]$interfaces,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"

        #get interface name from int ps object
        $interface = $int.name

        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        if ($interface -notlike "lag*") {
            throw "You can use only with LAG interface"
        }
        $_interface = Get-ArubaCXInterfaces $interface -selector writable -connection $connection

        #Remove name from vlan (can not be modified)
        $_interface.psobject.Properties.remove("name")

        #get list of existant interfaces
        $intf = $_interface.interfaces
        if ($intf) {
            foreach ($i in $intf.psobject.Properties.Name) {
                $interfaces += $i
            }
        }

        $members = @()
        #Add new vlan
        foreach ($member in $interfaces) {
            $members += "/rest/" + $($connection.api_version) + "/system/interfaces/" + ($member -replace '/', '%2F')
        }
        $_interface.interfaces = $members

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_interface -connection $connection
        $response
        Get-ArubaCXInterfaces $interface -connection $connection
    }

    End {
    }
}
function Get-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Get list of all Aruba CX Interfacess

      .DESCRIPTION
      Get list of all Aruba CX Interfaces (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXInterfaces

      Get list of all interface (lag/port/vlan)

      .EXAMPLE
      Get-ArubaCXInterfaces 1/1/1

      Get interface 1/1/1 info

      .EXAMPLE
      Get-ArubaCXInterfaces -interface vlan85

      Get interface vlan 85 info

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter(Mandatory = $false, position = 1)]
        [String]$interface,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4)]
        [Int]$depth,
        [Parameter(Mandatory = $false)]
        [ValidateSet("configuration", "status", "statistics", "writable")]
        [String]$selector,
        [Parameter(Mandatory = $false)]
        [String[]]$attributes,
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
        if ( $PsBoundParameters.ContainsKey('depth') ) {
            $invokeParams.add( 'depth', $depth )
        }
        if ( $PsBoundParameters.ContainsKey('selector') ) {
            #You need to specify an interface for use writable selector (it is not possible to use on collections...)
            if ( -not $PsBoundParameters.ContainsKey('interface') -and $selector -eq "writable") {
                Throw "You need to specify an interface to use writable selector"
            }
            $invokeParams.add( 'selector', $selector )
        }
        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $invokeParams.add( 'attributes', $attributes )
        }
        if ( $PsBoundParameters.ContainsKey('vsx_peer') ) {
            $invokeParams.add( 'vsx_peer', $true )
        }

        $uri = "system/interfaces"

        if ( $PsBoundParameters.ContainsKey('interface') ) {
            $interface = $interface -replace '/', '%2F'
            $uri += "/$interface"
        }

        $response = Invoke-ArubaCXRestMethod -uri $uri -method 'GET' -connection $connection @invokeParams

        #Add name parameter when use writable type selector
        if ( $PsBoundParameters.ContainsKey('selector') -and $selector -eq "writable" ) {
            $response | add-member -name "name" -membertype NoteProperty -Value $interface
        }

        $response
    }

    End {
    }
}


function Set-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Confgure Aruba CX Interfaces

      .DESCRIPTION
      Configure Aruba CX Interfaces (port, lag, vlan... with name, IP Address, description)

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -description "Changed by PowerArubaCX"

      Set the description "Change by PowerArubaCX" for the Interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -admin up

      Set the admin status to up for the Interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -routing:$false

      Set the routing to disable for the Interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -vlan_mode access -vlan_tag 85

      Set the interface 1/1/1 on access mode with vlan 85

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -vlan_mode native-untagged -vlan_tag 85 -vlan_trunks 44,45

      Set the interface 1/1/1 on native-untagged mode with vlan 85 and tagged vlan 44 and 45

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24

      Set the interface 1/1/1 with IPv4 Address 192.0.2.1/24

      .EXAMPLE
      Get-ArubaCXInterfaces -interface vlan85 | Set-ArubaCXInterfaces -ip4_address $null

      Remove IPv4 Address of interface vlan85

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -mtu 9198 -ip_mtu 9198

      Set MTU and IP MTU to 9198 (Default 1500)

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -vsx_virtual_gw_mac_v4 00:01:02:03:04:05 -vsx_virtual_ip4 192.0.2.254

      Set Active Gateway (vsx virtual gw/ip...) MAC and IPv4 interface 1/1/1
      You can use also following alias active_gateway_mac or active_gateway

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -vsx_virtual_ip4 192.0.2.1, 192.0.2.2

      Set Active Gateway IP (Primary and secondary) on interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Set-ArubaCXInterfaces -vrf MyVRF

      Set interface 1/1/1 on the vrf MyVRF

      .EXAMPLE
      Get-ArubaCXInterfaces -interface lag2 | Set-ArubaCXInterfaces -lag_interfaces

      Set interface 1/1/1 on the lag 2

      .EXAMPLE
      $int = Get-ArubaCXInterfaces -interface 1/1/1 -selector writable
      PS> $int.description = "My Vlan"
      PS> $int | Set-ArubaCXInterfaces -use_pipeline

      Configure some interfacevariable (description) no available on parameter using pipeline (can be only with selector equal writable)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "interface")]
        [String]$interface,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "int")]
        [ValidateScript( { Confirm-ArubaCXInterfaces $_ })]
        [psobject]$int,
        [Parameter(Mandatory = $false)]
        [ValidateSet('up', 'down')]
        [string]$admin,
        [Parameter(Mandatory = $false)]
        [string]$description,
        [Parameter(Mandatory = $false)]
        [switch]$routing,
        [Parameter(Mandatory = $false)]
        [ValidateSet('access', 'native-untagged', 'native-tagged', IgnoreCase = $false)]
        [string]$vlan_mode,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4096)]
        [int]$vlan_tag,
        [Parameter(Mandatory = $false)]
        #[ValidateRange(1, 4096)]
        [int[]]$vlan_trunks,
        [Parameter(Mandatory = $false)]
        [ipaddress]$ip4_address,
        [Parameter(Mandatory = $false)]
        [ValidateRange(8, 32)]
        [int]$ip4_mask,
        [Parameter(Mandatory = $false)]
        [ValidateRange(46, 9198)]
        [int]$mtu,
        [Parameter(Mandatory = $false)]
        [ValidateRange(68, 9198)]
        [int]$ip_mtu,
        [Parameter(Mandatory = $false)]
        [switch]$l3_counters_rx,
        [Parameter(Mandatory = $false)]
        [switch]$l3_counters_tx,
        [Parameter(Mandatory = $false)]
        [Alias('active_gateway_mac')]
        [string]$vsx_virtual_gw_mac_v4,
        [Parameter(Mandatory = $false)]
        [Alias('active_gateway')]
        [ipaddress[]]$vsx_virtual_ip4,
        [Parameter(Mandatory = $false)]
        [string]$vrf,
        [Parameter (Mandatory = $false)]
        [switch]$use_pipeline,
        [Parameter (Mandatory = $false)]
        [String[]]$lag_interfaces,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"

        #get interface name from int ps object
        if ($int) {
            $interface = $int.name
        }

        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        if ($use_pipeline) {
            $_interface = $int
        }
        else {
            $_interface = Get-ArubaCXInterfaces $interface -selector writable -connection $connection
        }

        #Remove name from vlan (can not be modified)
        $_interface.psobject.Properties.remove("name")

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_interface.description = $description
        }

        if ( $PsBoundParameters.ContainsKey('admin') ) {
            if ($interface -like "lag*") {
                $_interface.admin = $admin
            }
            else {
                if ($null -eq $_interface.user_config.admin) {
                    $_interface.user_config | Add-member -name "admin" -membertype NoteProperty -Value ""
                }
                $_interface.user_config.admin = $admin
            }
        }

        if ( $PsBoundParameters.ContainsKey('routing') ) {
            if ($routing) {
                $_interface.routing = $true
            }
            else {
                $_interface.routing = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vlan_mode') ) {
            $_interface.vlan_mode = $vlan_mode
        }

        if ( $PsBoundParameters.ContainsKey('vlan_tag') ) {
            $_interface.vlan_tag = "/rest/" + $($connection.api_version) + "/system/vlans/" + $vlan_tag
        }

        if ( $PsBoundParameters.ContainsKey('vlan_trunks') ) {
            $trunks = @()
            foreach ($trunk in $vlan_trunks) {
                $trunks += "/rest/" + $($connection.api_version) + "/system/vlans/" + $trunk
            }
            $_interface.vlan_trunks = $trunks
        }

        if ( $PsBoundParameters.ContainsKey('ip4_address') ) {
            if ($ip4_address -eq $null ) {
                $_interface.ip4_address = $null
            }
            else {
                if ($ip4_mask -eq "0" ) {
                    Throw "You need to set ip4_mask when use ipv4_address"
                }
                if ($_interface.routing -eq $false) {
                    Throw "You need to enable routing mode for use ipv4_address"
                }
                if ( -not ($ip4_address.AddressFamily -eq "InterNetwork" )) {
                    Throw "You need to specify a IPv4 Address"
                }
                $_interface.ip4_address = $ip4_address.ToString() + "/" + $ip4_mask
            }
        }

        if ( $PsBoundParameters.ContainsKey('mtu') ) {
            if ($null -eq $_interface.user_config.mtu) {
                $_interface.user_config | Add-member -name "mtu" -membertype NoteProperty -Value ""
            }
            $_interface.user_config.mtu = $mtu
        }

        if ( $PsBoundParameters.ContainsKey('ip_mtu') ) {
            $_interface.ip_mtu = $ip_mtu
        }

        if ( $PsBoundParameters.ContainsKey('l3_counters_rx') ) {
            if ($l3_counters_rx) {
                $_interface.l3_counters_enable.rx = $true
            }
            else {
                $_interface.l3_counters_enable.rx = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('l3_counters_tx') ) {
            if ($l3_counters_tx) {
                $_interface.l3_counters_enable.tx = $true
            }
            else {
                $_interface.l3_counters_enable.tx = $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('vsx_virtual_gw_mac_v4') ) {
            $_interface.vsx_virtual_gw_mac_v4 = $vsx_virtual_gw_mac_v4
        }

        if ( $PsBoundParameters.ContainsKey('vsx_virtual_ip4') ) {
            $ag_ip4 = @()

            foreach ($ip4 in $vsx_virtual_ip4) {
                $ag_ip4 += $ip4.ToString()
            }
            $_interface.vsx_virtual_ip4 = $ag_ip4
        }

        if ( $PsBoundParameters.ContainsKey('vrf') ) {
            $_interface.vrf = "/rest/" + $($connection.api_version) + "/system/vrfs/" + $vrf
        }

        #Only work for LAG interface
        if ( $PsBoundParameters.ContainsKey('lag_interfaces') ) {
            if ($interface -like "lag*") {
                $members = @()
                foreach ($member in $lag_interfaces) {
                    $members += "/rest/" + $($connection.api_version) + "/system/interfaces/" + ($member -replace '/', '%2F')
                }
                $_interface.interfaces = $members
            }
            else {
                throw "You can only use -lag_interfaces with lag interface"
            }
        }

        if ($PSCmdlet.ShouldProcess($interface, 'Configure interface Settings')) {
            Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_interface -connection $connection
        }
        Get-ArubaCXInterfaces $interface -connection $connection
    }

    End {
    }
}

function Remove-ArubaCXInterfaces {

    <#
      .SYNOPSIS
      Remove an interface

      .DESCRIPTION
      Remove an interface (vlan or lag)

      .EXAMPLE
      Get-ArubaCXInterfaces -interface vlan23 | Remove-ArubaCXInterfaces

      Remove vlan 23

      .EXAMPLE
      Get-ArubaCXInterfaces -interface lag2 | Remove-ArubaCXInterfaces -confirm:$false

      Remove lag 2 without confirmation

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCXInterfaces $_ })]
        [psobject]$int,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"

        #get interface name from int ps object
        $interface = $int.name

        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        if ($PSCmdlet.ShouldProcess($interface, 'Remove interface')) {
            Invoke-ArubaCXRestMethod -uri $uri -method 'DELETE' -connection $connection
        }
    }

    End {
    }
}

function Remove-ArubaCXInterfacesVlanTrunks {

    <#
      .SYNOPSIS
      Remove vlan on an interface

      .DESCRIPTION
      Remove vlan (tagged) on an interface

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks 44

      Remove vlan 44 to vlan trunks on interface 1/1/1

      .EXAMPLE
      Get-ArubaCXInterfaces -interface 1/1/1 | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks 44, 45

      Remove vlan 44 and 45 to vlan trunks on interface 1/1/1

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCXInterfaces $_ })]
        [psobject]$int,
        [Parameter(Mandatory = $true)]
        #[ValidateRange(1, 4096)]
        [int[]]$vlan_trunks,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCXConnection
    )

    Begin {
    }

    Process {

        $uri = "system/interfaces"

        #get interface name from int ps object
        $interface = $int.name

        #Add interface to $uri
        $interface = $interface -replace '/', '%2F'
        $uri += "/$interface"

        $_interface = Get-ArubaCXInterfaces $interface -selector writable -connection $connection

        #Remove name from vlan (can not be modified)
        $_interface.psobject.Properties.remove("name")

        #get list of existant vlan and recreate $trunk
        $vlans = $_interface.vlan_trunks
        $trunks = @()
        if ($vlans) {
            foreach ($v in $vlans.psobject.Properties.Name) {
                #Remove vlan ($v) if it is on vlan_trunks list
                if ($vlan_trunks -contains $v) {
                    continue
                }
                $trunks += "/rest/" + $($connection.api_version) + "/system/vlans/" + $v
            }
        }

        $_interface.vlan_trunks = $trunks

        if ($PSCmdlet.ShouldProcess($interface, 'Remove vlan tagged on interface')) {
            $response = Invoke-ArubaCXRestMethod -uri $uri -method 'PUT' -body $_interface -connection $connection
        }
        $response
        Get-ArubaCXInterfaces $interface -connection $connection
    }

    End {
    }
}