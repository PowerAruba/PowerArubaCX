#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Interfaces" {

    It "Get Interface Does not throw an error" {
        {
            Get-ArubaCXInterfaces
        } | Should Not Throw
    }

    It "Get ALL Interfaces" {
        $int = Get-ArubaCXInterfaces
        $int.count | Should not be $NULL
    }

    It "Get Interface ($pester_interface) and confirm (via Confirm-ArubaCXInterface)" {
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        Confirm-ArubaCXInterface $int | Should be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Interface with selector equal configuration" {
            {
                Get-ArubaCXInterfaces -selector configuration
            } | Should Not Throw
        }

        It "Get Interface with selector equal statistics" {
            {
                Get-ArubaCXInterfaces -selector statistics
            } | Should Not Throw
        }

        It "Get Interface with selector equal status" {
            {
                Get-ArubaCXInterfaces -selector status
            } | Should Not Throw
        }

        It "Get Interface with selector equal writable" {
            {
                Get-ArubaCXInterfaces -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Interface with depth equal 1" {
            {
                Get-ArubaCXInterfaces -depth 1
            } | Should Not Throw
        }

        It "Get Interface with depth equal 2" {
            {
                Get-ArubaCXInterfaces -depth 2
            } | Should Not Throw
        }

        It "Get Interface with depth equal 3" {
            {
                Get-ArubaCXInterfaces -depth 3
            } | Should Not Throw
        }

        It "Get Interface with depth equal 4" {
            {
                Get-ArubaCXInterfaces -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        #Bug with ArubaCX 10.04.0001 OVA
        It "Get Interface with one attribute (admin)" -skip:$true {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute status
            @($int).count | Should -be 1
            $int.name | Should -BeNullOrEmpty
            $int.status | Should -Not -BeNullOrEmpty
        }

        #Bug with ArubaCX 10.04.0001 OVA
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
            @($int).count | Should be 1
            $int.name | Should be "$pester_interface"
        }
        It "Search Interface by interface (using position) ($pester_interface)" {
            $int = Get-ArubaCXInterfaces $pester_interface
            @($int).count | Should be 1
            $int.name | Should be "$pester_interface"
        }
    }
}


Describe  "Configure Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Make a CheckPoint ?
    }

    It "Change interface description" {
        Set-ArubaCXInterfaces -interface $pester_interface -description "Modified by PowerArubaCX"
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.name | Should be "$pester_interface"
        $int.description | Should be "Modified by PowerArubaCX"
    }

    It "Change interface status (up)" {
        Set-ArubaCXInterfaces -interface $pester_interface -admin up
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should be "up"
    }

    It "Change interface status (down)" {
        Set-ArubaCXInterfaces -interface $pester_interface -admin down
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should be "down"
    }

    It "Change interface routing (disable)" {
        Set-ArubaCXInterfaces -interface $pester_interface -routing:$false
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should be $false
    }

    It "Change interface routing (enable)" {
        Set-ArubaCXInterfaces -interface $pester_interface -routing:$true
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should be $true
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
    }
}


Describe  "Configure Vlan on Interface" {
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
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
        $int.vlan_trunks | Should -Be $null
    }

    It "Change Interface ($pester_interface) trunks vlan ($pester_vlan)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-untagged"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
        $int.vlan_tag | Should -Be $null
        ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.version) + "/system/vlans/" + $pester_vlan)
    }

    It "Change Interface ($pester_interface) trunks with 2 vlan ($pester_vlan, $pester_vlan2)" {
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan, $pester_vlan2
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.vlan_mode | Should -Be "native-untagged"
        ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
        $int.vlan_tag | Should -Be $null
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

Describe  "Add Vlan trunk on Interface" {
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
        } | Should throw "You need to disable routing mode for use vlan_trunks"

        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode access
    }

    It "Try to set vlan_trunks on interface with vlan mode access" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
        } | Should throw "You need to use native-(un)tagged vlan mode"

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
        $int.vlan_truns | Should -Be $null
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline
        #Reverse CheckPoint ?
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false
    }
}

Describe  "Configure IP on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
        #Make a CheckPoint ?
    }

    It "Try to set ip4_address without ip4_mask" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 192.0.2.1
        } | Should throw "You need to set ip4_mask when use ipv4_address"
    }

    It "Try to set ip4_address on interface with no routing" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24
        } | Should throw "You need to enable routing mode for use ipv4_address"

        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
    }

    It "Try to set a IPv6 Address on interface" {
        {
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -ip4_address 2001:DB8::1 -ip4_mask 24
        } | Should throw "You need to specify a IPv4 Address"
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

Disconnect-ArubaCX -noconfirm