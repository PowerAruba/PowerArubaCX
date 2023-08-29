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
        @($int).count | Should -Not -Be $NULL
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
        #No longer bug with >= 10.06.000x and good attribute...
        It "Get Interface with one attribute (admin)" {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute type
            @($int).count | Should -be 1
            $int.name | Should -BeNullOrEmpty
            $int.type | Should -Not -BeNullOrEmpty
        }

        #Bug with ArubaCX 10.04.x (Tested with OVA 10.04.0001 and 8320 with 10.04.0030)
        #No longer bug with >= 10.06.000x and good attribute...
        It "Get Interface with two attributes (admin, name)" {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute name, type
            @($int).count | Should -be 1
            $int.id | Should -BeNullOrEmpty
            $int.name | Should -Be $pester_interface
            $int.type | Should -Not -BeNullOrEmpty

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

$inttypel3 = @(
    @{ "name" = $pester_interface }
    @{ "name" = "vlan" + $pester_vlan }
    @{ "name" = "loopback" + $pester_loopback }
    @{ "name" = "lag" + $pester_lag }
)

Describe "Configure Interface" {

    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
        #Make a CheckPoint ?

        # Add Vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        # and interface vlan
        Add-ArubaCXInterfaces -vlan_id $pester_vlan

        #Add Loopback interface
        Add-ArubaCXInterfaces -loopback_id $pester_loopback

        #Add Lag interface
        Add-ArubaCXInterfaces -lag_id $pester_lag
    }


    $inttypel3.ForEach{
        Context "Interface $($_.name)" {

            It "Change interface description" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -description "Modified by PowerArubaCX"
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be "Modified by PowerArubaCX"
            }

            It "Change interface status (up)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -admin up
                $int = Get-ArubaCXInterfaces -interface $_.name
                #With lag, there is no user_config but directly admin...
                if ($_.name -like "lag*") {
                    $int.admin | Should -Be "up"
                }
                else {
                    $int.user_config.admin | Should -Be "up"
                }
            }

            It "Change interface status (down)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -admin down
                $int = Get-ArubaCXInterfaces -interface $_.name
                #With lag, there is nothings ..
                if ($_.name -notlike "lag*") {
                    $int.user_config.admin | Should -Be "down"
                }
            }

            It "Change interface routing (disable)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$false
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.routing | Should -Be $false
            }

            It "Change interface routing (enable)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$true
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.routing | Should -Be $true
            }

            #Disable MTU change for LAG (can no be change...)
            It "Change interface MTU (9198)" -TestCases $_ -Skip:($_.name -eq "lag$pester_lag") {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -mtu 9198
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.user_config.mtu | Should -Be "9198"
            }

            It "Change interface IP MTU (9198)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip_mtu 9198
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.ip_mtu | Should -Be "9198"
            }

            It "Change interface l3 counters (Set enable for tx and tx)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -l3_counters_tx:$true -l3_counters_rx:$true
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.l3_counters_enable.rx | Should -Be $true
                $int.l3_counters_enable.tx | Should -Be $true
            }

            It "Change interface l3 counters (Set disable for tx and tx)" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -l3_counters_tx:$false -l3_counters_rx:$false
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.l3_counters_enable.rx | Should -Be $false
                $int.l3_counters_enable.tx | Should -Be $false
            }

            It "Change Active Gateway (vsx_virtual_gw_mac_v4) MAC" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vsx_virtual_gw_mac_v4 00:01:02:03:04:05
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.vsx_virtual_gw_mac_v4 | Should -Be "00:01:02:03:04:05"
            }

            It "Change Active Gateway (vsx_virtual_ip4) IP" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vsx_virtual_ip4 192.0.2.254
                $int = Get-ArubaCXInterfaces -interface $_.name
                ($int.vsx_virtual_ip4).count | should -Be "1"
                $int.vsx_virtual_ip4 | Should -Be "192.0.2.254"
            }

            It "Change Active Gateway (vsx_virtual_ip4) IP and a secondary" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vsx_virtual_ip4 192.0.2.1, 192.0.2.2
                $int = Get-ArubaCXInterfaces -interface $_.name
                ($int.vsx_virtual_ip4).count | should -Be "2"
                $int.vsx_virtual_ip4[0] | Should -Be "192.0.2.1"
                $int.vsx_virtual_ip4[1] | Should -Be "192.0.2.2"
            }

        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline
            #Reverse CheckPoint ?

            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false

            #Remove Lag interface
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }
}

$inttypel2 = @(
    @{ "name" = $pester_interface }
    @{ "name" = "lag" + $pester_lag }
)

$inttypenolagnophysical = @(
    @{ "name" = "vlan" + $pester_vlan }
    @{ "name" = "loopback" + $pester_loopback }
)

Describe "Configure Vlan on Interface" {

    Context "Configure Vlan on Interface physical and LAG" {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Add 2 vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

            #Set interface to mode brigde (no routing)
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode access
            #Make a CheckPoint ?

            #Add Lag interface
            Add-ArubaCXInterfaces -lag_id $pester_lag -vlan_mode access
        }

        $inttypel2.ForEach{
            Context "Interface $($_.name)" {
                It "Change Interface $($_.name) to native ($pester_vlan)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_tag $pester_vlan
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "access"
                    ($int.vlan_tag | Get-Member -MemberType NoteProperty).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                }

                It "Change Interface $($_.name) to native-untagged" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode native-untagged
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "native-untagged"
                    ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "0"
                    $int.vlan_trunks | Should -BeNullOrEmpty
                }

                It "Change Interface $($_.name) trunks vlan ($pester_vlan)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "native-untagged"
                    ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                }

                It "Change Interface $($_.name) trunks with 2 vlan ($pester_vlan, $pester_vlan2)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan, $pester_vlan2
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "native-untagged"
                    ($int.vlan_tag | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }

                It "Change Interface $($_.name) to native-tagged with vlan ($pester_vlan)" -TestCases $_ {
                    #Aruba OVA 10.04 don't like there is multiple vlan on trunks when use native-tagged...
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode native-tagged -vlan_tag $pester_vlan -vlan_trunks $pester_vlan
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "native-tagged"
                    @($int.vlan_tag).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    @($int.vlan_trunks).count | Should -Be "1"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                }

                It "Change Interface $($_.name) to access with vlan ($pester_vlan2)" -TestCases $_ {
                    #Need to set back the access vlan and remove trunks vlan...
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode access -vlan_tag $pester_vlan2 -vlan_trunks $null
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_mode | Should -Be "access"
                    @($int.vlan_tag).count | Should -Be "1"
                    $int.vlan_tag.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }
            }
        }
        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline
            #Reverse CheckPoint ?
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
            Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false

            #Remove Lag interface
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Try to Set Vlan not Interface LAG or physical" {
        BeforeAll {
            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolagnophysical.ForEach{
            It "Try to Set Vlan Mode to interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode access
                } | Should -Throw
            }

            It "Try to Set Vlan tag to interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_tag $pester_vlan
                } | Should -Throw
            }

            It "Try to Set Vlan Trunks to interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan
                } | Should -Throw
            }
        }

        AfterAll {
            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

}

Describe "Add Vlan trunk on Interface" {

    Context "Add Vlan on Interface physical and LAG" {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Add 2 vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

            #Set interface to mode routing
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
            #Make a CheckPoint ?

            #Add Lag interface
            Add-ArubaCXInterfaces -lag_id $pester_lag -vlan_mode access
        }

        $inttypel2.ForEach{
            Context "Interface $($_.name)" {

                It "Try to set vlan_trunks on interface with routing" -TestCases $_ {
                    {
                        Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                    } | Should -Throw "You need to disable routing mode for use vlan_trunks"

                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$false -vlan_mode access
                }

                It "Try to set vlan_trunks on interface with vlan mode access" -TestCases $_ {
                    {
                        Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                    } | Should -Throw "You need to use native-(un)tagged vlan mode"

                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$false -vlan_mode native-untagged
                }

                It "Add Vlan ($pester_vlan) trunks to an interface $($_.name)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                }

                It "Add Second Vlan ($pester_vlan2) trunks to an interface $($_.name)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan2
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }

                It "(re) Add Second Vlan ($pester_vlan2) trunks to an interface $($_.name)" -TestCases $_ {
                    #Should not Throw
                    Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan2
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }

                It "Add Vlans ($pester_vlan and $pester_vlan2) trunks to an interface $($_.name)" -TestCases $_ {
                    #reset vlan trunks
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode access -vlan_trunks $null
                    #Set now to native-tagged
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_mode native-untagged
                    Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan, $pester_vlan2
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "2"
                    $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                    $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline
            #Reverse CheckPoint ?
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
            Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false

            #Remove Lag interface
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Try to Add Vlan not Interface LAG or physical" {
        BeforeAll {
            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolagnophysical.ForEach{
            It "Try to Add Vlan to interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Add-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                } | Should -Throw
            }
        }

        AfterAll {
            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }
}
Describe "Remove Vlan trunk on Interface" {

    Context "Add Vlan on Interface physical and LAG" {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Add 2 vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            Add-ArubaCXVlans -id $pester_vlan2 -name pester_PowerArubaCX2

            #Set interface to mode no routing and vlan mode native untagged
            Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$false -vlan_mode native-untagged
            #Make a CheckPoint ?

            #Add Lag interface
            Add-ArubaCXInterfaces -lag_id $pester_lag -vlan_mode access
        }

        $inttypel2.ForEach{
            Context "Interface $($_.name)" {
                BeforeEach {
                    #Affect 2 Vlan on the interface
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vlan_trunks $pester_vlan, $pester_vlan2
                }

                It "Remove Vlan ($pester_vlan) trunks to an interface $($_.name)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    ($int.vlan_trunks | Get-Member -MemberType NoteProperty).count | Should -Be "1"
                    $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
                }

                It "Remove Vlans ($pester_vlan and $pester_vlan2) trunks to an interface $($_.name)" -TestCases $_ {
                    Get-ArubaCXInterfaces -interface $_.name | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan, $pester_vlan2
                    $int = Get-ArubaCXInterfaces -interface $_.name
                    $int.vlan_tag | Should -Be $null
                    $int.vlan_trunks | Should -BeNullOrEmpty
                }
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline
            #Reverse CheckPoint ?
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
            Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false

            #Remove Lag interface
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Try to Remove Vlan not Interface LAG or physical" {
        BeforeAll {
            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolagnophysical.ForEach{
            It "Try to Remove Vlan to interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Remove-ArubaCXInterfacesVlanTrunks -vlan_trunks $pester_vlan
                } | Should -Throw
            }
        }

        AfterAll {
            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }
}

Describe "Configure IP on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true
        #Make a CheckPoint ?

        # Add Vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        # and interface vlan
        Add-ArubaCXInterfaces -vlan_id $pester_vlan

        #Add Loopback interface
        Add-ArubaCXInterfaces -loopback_id $pester_loopback

        #Add Lag interface
        Add-ArubaCXInterfaces -lag_id $pester_lag
    }

    $inttypel3.ForEach{
        Context "Interface $($_.name)" {
            It "Try to set ip4_address without ip4_mask" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip4_address 192.0.2.1
                } | Should -Throw "You need to set ip4_mask when use ipv4_address"
            }

            It "Try to set ip4_address on interface with no routing" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$false
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24
                } | Should -Throw "You need to enable routing mode for use ipv4_address"

                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -routing:$true
            }

            It "Try to set an IPv6 Address on interface" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip4_address 2001:DB8::1 -ip4_mask 24
                } | Should -Throw "You need to specify an IPv4 Address"
            }

            It "Set ip4_address on interface" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip4_address 192.0.2.1 -ip4_mask 24
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.ip4_address | Should -Be "192.0.2.1/24"
            }

            It "Set ip4_address to default on interface" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -ip4_address $null
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.ip4_address | Should -Be $null
            }
        }
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline

        #Remove Vlan Interface
        Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
        #Remove vlan
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

        #Remove Loopback interface
        Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false

        #Remove Lag interface
        Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
    }
}

Describe "Configure VRF on Interface" {
    BeforeAll {
        $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable

        #Set interface to mode routing
        Get-ArubaCXInterfaces -interface $pester_interface | Set-ArubaCXInterfaces -routing:$true

        # Add Vlan
        Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
        # and interface vlan
        Add-ArubaCXInterfaces -vlan_id $pester_vlan

        #Add Loopback interface
        Add-ArubaCXInterfaces -loopback_id $pester_loopback

        #Add Lag interface
        Add-ArubaCXInterfaces -lag_id $pester_lag


        #Create the vrf
        Add-ArubaCXVrfs -name $pester_vrf
    }

    $inttypel3.ForEach{
        Context "Interface $($_.name)" {
            It "Attach vrf ($pester_vrf) to an interface $($_.name))" -TestCases $_ {
                Get-ArubaCXInterfaces -interface $_.name | Set-ArubaCXInterfaces -vrf $pester_vrf
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.vrf.$pester_vrf | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + $pester_vrf)
            }
        }
    }

    AfterAll {
        $default_int | Set-ArubaCXInterfaces -use_pipeline

        #Remove Vlan Interface
        Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
        #Remove vlan
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

        #Remove Loopback interface
        Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false

        #Remove Lag interface
        Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false

        #Remove vrf
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
    }
}

$inttypeadd = @(
    @{ "name" = "vlan" + $pester_vlan }
    @{ "name" = "loopback" + $pester_loopback }
    @{ "name" = "lag" + $pester_lag }
)

$inttypeaddl2 = @(
    @{ "name" = "lag" + $pester_lag }
)

Describe "Add Interface" {

    $inttypeadd.ForEach{
        Context "Add Interface $($_.name) (Commun)" {
            BeforeAll {
                Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX
                #Make a CheckPoint ?

                #Create the vrf
                Add-ArubaCXVrfs -name $pester_vrf
            }
            AfterEach {
                Get-ArubaCXInterfaces -interface $($_.name) | Remove-ArubaCXInterfaces -confirm:$false
            }

            It "Add Interface $($_.name) (with only an id)" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                    $type = "vlan"
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                    $type = "loopback"
                }
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag }
                    #type is not specified for lag... (before 10.10...)
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                if ($_.name -like "lag*") {
                    #lag don't use the same attribute for admin status... (and it is not specified by default...)
                    #$int.admin | Should -Be "up"
                }
                else {
                    $int.admin_state | Should -Be "up"
                }
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $true
            }

            It "Add Interface $($_.name) (with an id, description)" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                    $type = "vlan"
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                    $type = "loopback"
                }
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -description "Add via PowerArubaCX"
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be "Add via PowerArubaCX"
                $int.type | Should -Be $type
                if ($_.name -like "lag*") {
                    $int.admin | Should -Be "up"
                }
                else {
                    $int.admin_state | Should -Be "up"
                }
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $true
            }

            It "Add Interface $($_.name) (with an id and status down)" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                    $type = "vlan"
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                    $type = "loopback"
                }
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -admin down
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                if ($_.name -like "lag*") {
                    $int.admin | Should -Be "down"
                }
                else {
                    $int.admin_state | Should -Be "down"
                }
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $true
            }

            It "Add Interface $($_.name) (with an id and IP4 Address (and mask))" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                    $type = "vlan"
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                    $type = "loopback"
                }
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -ip4_address 192.0.2.1 -ip4_mask 24
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                if ($_.name -like "lag*") {
                    $int.admin | Should -Be "up"
                }
                else {
                    $int.admin_state | Should -Be "up"
                }
                $int.ip4_address | Should -Be "192.0.2.1/24"
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $true
            }

            It "Add Interface $($_.name) (with an id and a vrf)" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                    $type = "vlan"
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                    $type = "loopback"
                }
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -vrf $pester_vrf
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                if ($_.name -like "lag*") {
                    $int.admin | Should -Be "up"
                }
                else {
                    $int.admin_state | Should -Be "up"
                }
                $int.ip4_address | Should -Be $null
                $int.vrf.$pester_vrf | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + $pester_vrf)
                $int.routing | Should -Be $true
            }
            AfterAll {
                Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
                #Reverse CheckPoint ?

                #Remove vrf
                Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
            }
        }

    }

    $inttypeaddl2.ForEach{
        Context "Add Interface $($_.name) (L2)" {
            BeforeAll {
                Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX
                Add-ArubaCXVlans -id $pester_vlan2 -name PowerArubaCX2
                #Make a CheckPoint ?

                #Create the vrf
                Add-ArubaCXVrfs -name $pester_vrf
            }

            AfterEach {
                Get-ArubaCXInterfaces -interface $($_.name) | Remove-ArubaCXInterfaces -confirm:$false
            }

            It "Add Interface $($_.name) (with an id, status up and routing disable)" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode access)" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode access
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "access"
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-untagged)" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-untagged
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-untagged"
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-tagged)" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-tagged
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-tagged"
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode access on vlan $pester_vlan)" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode access -vlan_tag $pester_vlan
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "access"
                @($int.vlan_tag).count | Should -Be "1"
                $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-untagged on vlan $pester_vlan (native) and $pester_vlan2 (tagged))" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-untagged -vlan_tag $pester_vlan -vlan_trunks $pester_vlan2
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-untagged"
                @($int.vlan_tag.psobject.properties.name).count | Should -Be "1"
                $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                @($int.vlan_trunks.psobject.properties.name).count | Should -Be "1"
                $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-untagged on vlan $pester_vlan (native and tagged) and $pester_vlan2 (tagged))" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-untagged -vlan_trunks $pester_vlan, $pester_vlan2
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-untagged"
                @($int.vlan_tag.psobject.properties.name).count | Should -Be "1"
                @($int.vlan_trunks.psobject.properties.name).count | Should -Be "2"
                $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-tagged on vlan $pester_vlan (native) and $pester_vlan2 (tagged))" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-tagged -vlan_tag $pester_vlan -vlan_trunks $pester_vlan2
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-tagged"
                @($int.vlan_tag.psobject.properties.name).count | Should -Be "1"
                $int.vlan_tag.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                @($int.vlan_trunks.psobject.properties.name).count | Should -Be "1"
                $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
            }

            It "Add Interface $($_.name) (with an id, status up, routing disable and vlan_mode native-tagged on vlan $pester_vlan (native and tagged) and $pester_vlan2 (tagged))" -TestCases $_ {
                if ($_.name -like "lag*") {
                    $lag = $_.name -replace "lag", ""
                    $invokeParams = @{ "lag" = $lag; "admin" = "up" }
                    if ($DefaultArubaCXConnection.version.minor -ge "10") {
                        $type = "lag"
                    }
                    else {
                        $type = $null
                    }
                }
                Add-ArubaCXInterfaces @invokeParams -routing:$false -vlan_mode native-tagged -vlan_trunks $pester_vlan, $pester_vlan2
                $int = Get-ArubaCXInterfaces -interface $_.name
                $int.name | Should -Be $_.name
                $int.description | Should -Be $null
                $int.type | Should -Be $type
                $int.bond_status | Should -Be -Not $null
                $int.admin | Should -Be "up"
                $int.ip4_address | Should -Be $null
                $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
                $int.routing | Should -Be $false
                $int.interfaces | Should -BeNullOrEmpty
                $int.vlan_mode | Should -Be "native-tagged"
                @($int.vlan_tag.psobject.properties.name).count | Should -Be "1"
                @($int.vlan_trunks.psobject.properties.name).count | Should -Be "2"
                $int.vlan_trunks.$pester_vlan | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan)
                $int.vlan_trunks.$pester_vlan2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vlans/" + $pester_vlan2)
            }

            AfterAll {
                Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
                Get-ArubaCXVlans -id $pester_vlan2 | Remove-ArubaCXVlans -confirm:$false
                #Reverse CheckPoint ?

                #Remove vrf
                Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
            }
        }
    }

}

$inttypenolag = @(
    @{ "name" = $pester_interface }
    @{ "name" = "vlan" + $pester_vlan }
    @{ "name" = "loopback" + $pester_loopback }
)
Describe "LAG specific" {

    Context "Add Interface LAG with members" {

        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Add Interface lag $pester_lag (with an id, status up and an interface)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -interfaces $pester_interface -admin up
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "1"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
        }

        It "Add Interface lag $pester_lag (with an id, status up and 2 interfaces)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -interfaces $pester_interface, $pester_interface2 -admin up
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "2"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
            $int.interfaces.$pester_interface2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface2 -replace "/", "%2F"))
        }

    }

    Context "Try to Add member to no LAG interface " {

        $inttypenolagnophysical.ForEach{

            It "Try to Add member to no LAG interface $($_.name)" -TestCases $_ {
                if ($_.name -like "vlan*") {
                    $vlan_id = $_.name -replace "vlan", ""
                    $invokeParams = @{ "vlan_id" = $vlan_id }
                }
                if ($_.name -like "loopback*") {
                    $loopback = $_.name -replace "loopback", ""
                    $invokeParams = @{ "loopback" = $loopback }
                }
                {
                    Add-ArubaCXInterfaces @invokeParams -interfaces $pester_interface
                } | Should -Throw
            }

        }

    }

    Context "Set Interface LAG with members" {
        BeforeEach {
            #Add a Lag
            Add-ArubaCXInterfaces -lag_id $pester_lag -interfaces $pester_interface -admin up
        }

        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Set an interface member on lag $pester_lag " {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "1"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
        }

        It "Set 2 interfaces members on lag $pester_lag" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface, $pester_interface2
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "2"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
            $int.interfaces.$pester_interface2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface2 -replace "/", "%2F"))
        }
    }

    Context "Try to Set member to no LAG interface " {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Make a CheckPoint ?

            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolag.ForEach{
            It "Try to set member to no LAG interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Set-ArubaCXInterfaces -lag_interfaces $pester_interface
                } | Should -Throw
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline

            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Add members (interfaces) on LAG " {
        BeforeEach {
            #Add a Lag
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up
        }

        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Add an interface member on lag $pester_lag " {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Add-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "1"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
        }

        It "Add 2 interfaces members on lag $pester_lag" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Add-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface, $pester_interface2
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "2"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
            $int.interfaces.$pester_interface2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface2 -replace "/", "%2F"))
        }

        It "Add 1 interface member on lag $pester_lag (with already one member)" {
            #Add/Set a first member
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Add-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface2
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "2"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
            $int.interfaces.$pester_interface2 | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface2 -replace "/", "%2F"))
        }

        It "(re) Add 1 interface member on lag $pester_lag (with the same member)" {
            #Add/Set a first member
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface
            #Re Add the same interface...
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Add-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "1"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
        }
    }

    Context "Try to Add member to no LAG interface " {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Make a CheckPoint ?

            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolag.ForEach{
            It "Try to Add member to no LAG interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Add-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface
                } | Should -Throw
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline

            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Remove members (interfaces) on LAG " {
        BeforeEach {
            #Add a Lag with one interface
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -interfaces $pester_interface
        }

        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Remove an interface member on lag $pester_lag" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.interfaces | Should -BeNullOrEmpty
            #@($int.interfaces.psobject.properties.name).count | Should -Be "0"
        }

        It "Remove 2 interfaces members on lag $pester_lag" {
            #Add/Set 2 members
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface, $pester_interface2
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface, $pester_interface2
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.interfaces | Should -BeNullOrEmpty
            #@($int.interfaces.psobject.properties.name).count | Should -Be $null
        }

        It "Remove 1 interface member on lag $pester_lag (with already one member)" {
            #Add/Set 2 members
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lag_interfaces $pester_interface, $pester_interface2
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface2
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            @($int.interfaces.psobject.properties.name).count | Should -Be "1"
            $int.interfaces.$pester_interface | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/interfaces/" + ($pester_interface -replace "/", "%2F"))
        }
    }

    Context "Try to Remove member to no LAG interface " {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Make a CheckPoint ?

            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolag.ForEach{
            It "Try to Remove member to no LAG interface $($_.name)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Remove-ArubaCXInterfacesLagInterfaces -interfaces $pester_interface
                } | Should -Throw
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline

            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

    Context "Add Interface LAG specific (lacp, fallback, mclag)" {
        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Add Interface lag $pester_lag (with an id, lacp passive)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp passive
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.lacp | Should -Be "passive"
        }

        It "Add Interface lag $pester_lag (with an id, lacp active)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp active
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.lacp | Should -Be "active"

        }

        It "Add Interface lag $pester_lag (with an id, mclag enable)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -mclag
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.mclag_enabled | Should -Be $true
        }

        It "Add Interface lag $pester_lag (with an id, mclag disable)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -mclag:$false
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.mclag_enabled | Should -Be $false
        }

        It "Add Interface lag $pester_lag (with an id, lacp_fallback enabled)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp_fallback
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-fallback' | Should -Be $true
        }

        It "Add Interface lag $pester_lag (with an id, lacp_fallback disable)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp_fallback:$false
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-fallback' | Should -Be $false
        }

        It "Add Interface lag $pester_lag (with an id, lacp_time slow)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp_time slow
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-time' | Should -Be "slow"
        }

        It "Add Interface lag $pester_lag (with an id, lacp_time fast)" {
            Add-ArubaCXInterfaces -lag_id $pester_lag -admin up -lacp_time fast
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-time' | Should -Be "fast"
        }
    }

    Context "Set Interface LAG specific (lacp, fallback, mclag)" {
        BeforeEach {
            #Add a Lag
            Add-ArubaCXInterfaces -lag_id $pester_lag -interfaces $pester_interface -admin up
        }

        AfterEach {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Remove-ArubaCXInterfaces -confirm:$false
        }

        It "Set an interface lag $pester_lag (with lacp passive)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp passive
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.lacp | Should -Be "passive"
        }

        It "Set an interface lag $pester_lag (with lacp active)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp active
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.lacp | Should -Be "active"
        }
        <# Disable because you can not enable mclag after create LAG (but you can disable....)
        It "Set an interface lag $pester_lag (with mclag enabled)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -mclag
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            } else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.mclag_enabled | Should -Be $true
        }

        It "Set an interface lag $pester_lag (with mclag disable)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -mclag:$false
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            } else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.mclag_enabled | Should -Be $false
        }
        #>
        It "Set an interface lag $pester_lag (with lacp_fallback enabled)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp_fallback
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-fallback' | Should -Be $true
        }

        It "Set an interface lag $pester_lag (with lacp_fallback disable)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp_fallback:$false
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $DefaultArubaCXConnection.version.minor
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-fallback' | Should -Be $false
        }

        It "Set an interface lag $pester_lag (with lacp_time slow)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp_time slow
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-time' | Should -Be "slow"
        }

        It "Set an interface lag $pester_lag (with lacp_time fast)" {
            Get-ArubaCXInterfaces -interface "lag$pester_lag" | Set-ArubaCXInterfaces -lacp_time fast
            $int = Get-ArubaCXInterfaces -interface "lag$pester_lag"
            $int.name | Should -Be "lag$pester_lag"
            $int.description | Should -Be $null
            if ($DefaultArubaCXConnection.version.minor -ge "10") {
                $int.type | Should -Be "lag"
            }
            else {
                $int.type | Should -Be $null
            }
            $int.bond_status | Should -Be -Not $null
            $int.admin | Should -Be "up"
            $int.ip4_address | Should -Be $null
            $int.vrf.default | Should -Be ("/rest/" + $($DefaultArubaCXConnection.api_version) + "/system/vrfs/" + "default")
            $int.routing | Should -Be $true
            $int.other_config.'lacp-time' | Should -Be "fast"
        }
    }

    Context "Try to Set Interface LAG specific (lacp, fallback, rate)  to no LAG interface " {
        BeforeAll {
            $script:default_int = Get-ArubaCXInterfaces $pester_interface -selector writable
            #Make a CheckPoint ?

            # Add Vlan
            Add-ArubaCXVlans -id $pester_vlan -name pester_PowerArubaCX
            # and interface vlan
            Add-ArubaCXInterfaces -vlan_id $pester_vlan

            #Add Loopback interface
            Add-ArubaCXInterfaces -loopback_id $pester_loopback
        }

        $inttypenolag.ForEach{
            It "Try to Set Interface Lag Specific to no LAG interface $($_.name) (lacp)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Set-ArubaCXInterfaces -lacp passive
                } | Should -Throw
            }

            It "Try to Set Interface Lag Specific to no LAG interface $($_.name) (lacp fallback)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Set-ArubaCXInterfaces -lacp_fallback
                } | Should -Throw
            }

            It "Try to Set Interface Lag Specific to no LAG interface $($_.name) (lacp rate)" -TestCases $_ {
                {
                    Get-ArubaCXInterfaces -interface $($_.name) | Set-ArubaCXInterfaces -lacp_time slow
                } | Should -Throw
            }
        }

        AfterAll {
            $default_int | Set-ArubaCXInterfaces -use_pipeline

            #Remove Vlan Interface
            Get-ArubaCXInterfaces -interface "vlan$pester_vlan" | Remove-ArubaCXInterfaces -confirm:$false
            #Remove vlan
            Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false

            #Remove Loopback interface
            Get-ArubaCXInterfaces -interface "loopback$pester_loopback" | Remove-ArubaCXInterfaces -confirm:$false
        }
    }

}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}