#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCX @invokeParams
}

Describe "Get Interfaces" {

    It "Get Interface Does not throw an error" {
        {
            Get-ArubaCXInterfaces
        } | Should -Not -Throw
    }

    It "Get ALL Interfaces" {
        $int = Get-ArubaCXInterfaces
        $int.count | Should -Not -Be $NULL
    }

    It "Get Interface ($pester_interface) and confirm (via Confirm-ArubaCXInterfaces)" {
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        Confirm-ArubaCXInterfaces $int | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Interface with selector equal configuration" {
            {
                Get-ArubaCXInterfaces -selector configuration
            } | Should -Not -Throw
        }

        It "Get Interface with selector equal statistics" {
            {
                Get-ArubaCXInterfaces -selector statistics
            } | Should -Not -Throw
        }

        It "Get Interface with selector equal status" {
            {
                Get-ArubaCXInterfaces -selector status
            } | Should -Not -Throw
        }

        It "Get Interface with selector equal writable without interface" {
            {
                Get-ArubaCXInterfaces -selector writable
            } | Should -Throw
        }

        It "Get Interface with selector equal writable with interface" {
            {
                Get-ArubaCXInterfaces $pester_interface -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get Interface with depth equal 1" {
            {
                Get-ArubaCXInterfaces -depth 1
            } | Should -Not -Throw
        }

        It "Get Interface with depth equal 2" {
            {
                Get-ArubaCXInterfaces -depth 2
            } | Should -Not -Throw
        }

        It "Get Interface with depth equal 3" {
            {
                Get-ArubaCXInterfaces -depth 3
            } | Should -Not -Throw
        }

        It "Get Interface with depth equal 4" {
            {
                Get-ArubaCXInterfaces -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        #Bug with ArubaCX 10.04.x (Tested with OVA 10.04.0001 and 8320 with 10.04.0030)
        It "Get Interface with one attribute (admin)" -skip:$true {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute status
            @($int).count | Should -be 1
            $int.name | Should -BeNullOrEmpty
            $int.status | Should -Not -BeNullOrEmpty
        }

        #Bug with ArubaCX 10.04.x (Tested with OVA 10.04.0001 and 8320 with 10.04.0030)
        It "Get Interface with two attributes (admin, name)" -skip:$true {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute admin, name
            @($int).count | Should -be 1
            $int.id | Should -BeNullOrEmpty
            $int.status | Should -Not -BeNullOrEmpty
            $int.name | Should -Be $pester_interface
        }

    }

    Context "Search" {
        It "Search Interface by interface ($pester_interface)" {
            $int = Get-ArubaCXInterfaces -interface $pester_interface
            @($int).count | Should -Be 1
            $int.name | Should -Be "$pester_interface"
        }
        It "Search Interface by interface (using position) ($pester_interface)" {
            $int = Get-ArubaCXInterfaces $pester_interface
            @($int).count | Should -Be 1
            $int.name | Should -Be "$pester_interface"
        }
    }
}


Describe "Configure Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Make a CheckPoint ?
    }

    It "Change interface description" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -description "Modified by PowerArubaCX"
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.name | Should -Be "$pester_interface"
        $int.description | Should -Be "Modified by PowerArubaCX"
    }

    It "Change interface status (up)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -admin up
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should -Be "up"
    }

    It "Change interface status (down)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -admin down
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should -Be "down"
    }

    It "Change interface routing (disable)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should -Be $false
    }

    It "Change interface routing (enable)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should -Be $true
    }

    It "Change interface MTU (9198)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -mtu 9198
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.mtu | Should -Be "9198"
    }

    It "Change interface IP MTU (9198)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip_mtu 9198
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.ip_mtu | Should -Be "9198"
    }

    It "Change interface routing (Set enable for tx and tx)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -l3_counters_tx:$true -l3_counters_rx:$true
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.l3_counters_enable.rx | Should -Be $true
        $int.l3_counters_enable.tx | Should -Be $true
    }

    It "Change interface l3 counters (Set disable for tx and tx)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -l3_counters_tx:$false -l3_counters_rx:$false
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.l3_counters_enable.rx | Should -Be $false
        $int.l3_counters_enable.tx | Should -Be $false
    }

    #it is set on interface (1/1/x) but don't work for the moment (10.04.0030) with Vlan (get internal error)
    It "Change Active Gateway (vsx_virtual_gw_mac_v4) MAC" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vsx_virtual_gw_mac_v4 00:01:02:03:04:05
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vsx_virtual_gw_mac_v4 | Should -Be "00:01:02:03:04:05"
    }

    It "Change Active Gateway (vsx_virtual_ip4) IP" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vsx_virtual_ip4 192.0.2.254
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        ($int.vsx_virtual_ip4).count | should -Be "1"
        $int.vsx_virtual_ip4 | Should -Be "192.0.2.254"

    }

    It "Change Active Gateway (vsx_virtual_ip4) IP and a secondary" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vsx_virtual_ip4 192.0.2.1, 192.0.2.2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        ($int.vsx_virtual_ip4).count | should -Be "2"
        $int.vsx_virtual_ip4[0] | Should -Be "192.0.2.1"
        $int.vsx_virtual_ip4[1] | Should -Be "192.0.2.2"
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
    }
}


Describe "Configure Vlan on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Add 2 vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

        #Set interface to mode brigde (no routing)
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode access
        #Make a CheckPoint ?
    }

    It "Change Interface ($pester_interface) to native ($pester_vlan)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_tag $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "access"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
    }

    It "Change Interface ($pester_interface) to native-untagged" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_mode native-untagged
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-untagged"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
        $int.vlan_trunks | Should -BeNullOrEmpty
    }

    It "Change Interface ($pester_interface) trunks vlan ($pester_vlan)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-untagged"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
    }

    It "Change Interface ($pester_interface) trunks with 2 vlan ($pester_vlan, $pester_vlan2)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan, $pester_vlan2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-untagged"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan2)
    }

    It "Change Interface ($pester_interface) to native-tagged with vlan ($pester_vlan)" {
        #Aruba OVA 10.04 don't like there is multiple vlan on trunks when use native-tagged...
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_mode native-tagged -vlan_tag $pester_vlan -vlan_trunks $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-tagged"
        ($int.vlan_tag).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        ($int.vlan_trunks).count | Should -Be "1"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
    }

    It "Change Interface ($pester_interface) to access with vlan ($pester_vlan2)" {
        #Need to set back the access vlan and remove trunks vlan...
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_mode access -vlan_tag $pester_vlan2 -vlan_trunks $null
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "access"
        ($int.vlan_tag).count | Should -Be "1"
        $int.vlan_tag.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan2)
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false
    }
}

Describe "Add Vlan trunk on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Add 2 vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
        #Make a CheckPoint ?
    }

    It "Try to set vlan_trunks on interface with routing" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
        } | Should -Throw "You need to disable routing mode for use vlan_trunks"

        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode access
    }

    It "Try to set vlan_trunks on interface with vlan mode access" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
        } | Should -Throw "You need to use native-(un)tagged vlan mode"

        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode native-untagged
    }

    It "Add Vlan ($pester_vlan) trunks to an interface ($pester_interface)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
    }

    It "Add Second Vlan ($pester_vlan2) trunks to an interface ($pester_interface)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan2)
    }

    It "Add Vlans ($pester_vlan and $pester_vlan2) trunks to an interface ($pester_interface)" {
        #reset vlan trunks
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_mode access -vlan_trunks $null
        #Set now to native-tagged
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_mode native-untagged
        Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan, $pester_vlan2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
        $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan2)
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false
    }
}

Describe "Remove Vlan trunk on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Add 2 vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

        #Set interface to mode no routing and vlan mode native untagged
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode native-untagged
        #Make a CheckPoint ?
    }
    BeforeEach {
        #Affect 2 Vlan on the interface
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan, $pester_vlan2
    }

    It "Remove Vlan ($pester_vlan) trunks to an interface ($pester_interface)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan2)
    }

    It "Remove Vlans ($pester_vlan and $pester_vlan2) trunks to an interface ($pester_interface)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan, $pester_vlan2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_tag | Should -Be $null
        $int.vlan_trunks | Should -Be $null
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false
    }
}

Describe "Configure IP on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
        #Make a CheckPoint ?
    }

    It "Try to set ip4_address without ip4_mask" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 192.0.2.1
        } | Should -Throw "You need to set ip4_mask when use ipv4_address"
    }

    It "Try to set ip4_address on interface with no routing" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24
        } | Should -Throw "You need to enable routing mode for use ipv4_address"

        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
    }

    It "Try to set a IPv6 Address on interface" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 2001:DB8::1 -ip4_mask 24
        } | Should -Throw "You need to specify a IPv4 Address"
    }

    It "Set ip4_address on interface" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.ip4_address | Should -Be "192.0.2.1/24"
    }

    It "Set ip4_address to default on interface" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address $null
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.ip4_address | Should -Be $null
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
    }
}

Describe "Configure VRF on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true

        #Create the vrf
        Add-ArubaCXVrfs -name $pester_vrf
    }

    It "Attach vrf ($pester_vrf) to an interface ($pester_interface)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vrf $pester_vrf
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vrf.$pester_vrf | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vrfs/" + $pester_vrf)
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline

        #Remove vrf
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}