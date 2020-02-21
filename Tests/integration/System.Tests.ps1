#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get System" {
    It "Get System Does not throw an error" {
        {
            Get-ArubaCXSystem
        } | Should Not Throw
    }

    It "Get System ($pester_vlan) and confirm (via Confirm-ArubaCXSystem)" {
        $sys = Get-ArubaCXSystem
        Confirm-ArubaCXSystem ($sys) | Should be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get System with selector equal configuration" {
            {
                Get-ArubaCXSystem -selector configuration
            } | Should Not Throw
        }

        It "Get System with selector equal statistics" {
            {
                Get-ArubaCXSystem -selector statistics
            } | Should Not Throw
        }

        It "Get System with selector equal status" {
            {
                Get-ArubaCXSystem -selector status
            } | Should Not Throw
        }

        It "Get System with selector equal writable" {
            {
                Get-ArubaCXSystem -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get System with depth equal 1" {
            {
                Get-ArubaCXSystem -depth 1
            } | Should Not Throw
        }

        It "Get System with depth equal 2" {
            {
                Get-ArubaCXSystem -depth 2
            } | Should Not Throw
        }

        #Skip because fail actually with ArubaCX OVF 10.04.0001
        It "Get System with depth equal 3" -Skip:$true {
            {
                Get-ArubaCXSystem -depth 3
            } | Should Not Throw
        }

        #Skip because fail actually with ArubaCX OVF 10.04.0001
        It "Get System with depth equal 4" -Skip:$true {
            {
                Get-ArubaCXSystem -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        It "Get system with one attribute (hostname)" {
            $sys = Get-ArubaCXSystem -attribute hostname
            $sys.hostname | Should -Not -BeNullOrEmpty
        }

        It "Get system with two attributes (hostname, timezone)" {
            $sys = Get-ArubaCXSystem  -attribute hostname, timezone
            $sys.hostname | Should -Not -BeNullOrEmpty
            $sys.timezone | Should -Not -BeNullOrEmpty
        }

    }

}

Describe  "Configure System" {
    AfterAll {
        $script:default_sys = Get-ArubaCXSystem -selector writable
        #Add CheckPoint ?
    }
    It "Change System hostname" {
        Set-ArubaCXSystem -hostname "PowerArubaCX-Hostname"
        $sys = Get-ArubaCXSystem
        $sys.hostname | Should -Be "PowerArubaCX-Hostname"
    }

    It "Change System usb_disable using -use_pipeline" {
        $sys = Get-ArubaCXSystem -selector writable
        $sys.usb_disable = $false
        $sys | Set-ArubaCXSystem -use_pipeline
        $sys = Get-ArubaCXSystem
        $sys.usb_disable | Should -Be $false
    }

    It "Change System timezone" {
        Set-ArubaCXSystem -timezone Europe/Paris
        $sys = Get-ArubaCXSystem
        $sys.timezone | Should be "Europe/Paris"
    }

    It "Change System banner" {
        Set-ArubaCXSystem -Banner "PowerArubaCX-Banner"
        $sys = Get-ArubaCXSystem
        $sys.other_config.banner | Should -Be "PowerArubaCX-Banner"
    }

    AfterAll {
        $default_sys | Set-ArubaCXSystem -use_pipeline
        #Reverse CheckPoint ?
    }
}


Disconnect-ArubaCX -confirm:$false