#
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get RADIUS Server" {
    BeforeAll {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1 -auth_type pap -timeout 15 -retries 1
    }

    It "Get RADIUS Server Does not throw an error" {
        {
            Get-ArubaCXRadiusServer
        } | Should -Not -Throw
    }

    It "Get ALL RADIUS Server" {
        $radius = Get-ArubaCXRadiusServer
        @($radius).count | Should -Not -Be $NULL
    }

    It "Get RADIUS Server ($pester_radius_address)" {
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.address | Should -Be $pester_radius_address
        $radius.port | Should -Be $pester_radius_port
    }

    It "Get RADIUS Server ($pester_radius_address) and confirm (via Confirm-ArubaCXRadiusServer)" {
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        Confirm-ArubaCXRadiusServer ($radius) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get RADIUS Server with selector equal configuration" {
            {
                Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -selector configuration
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with selector equal statistics" {
            {
                Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -selector statistics
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with selector equal status" {
            {
                Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -selector status
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with selector equal writable" {
            {
                Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get RADIUS Server with depth equal 1" {
            {
                Get-ArubaCXRadiusServer -depth 1
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with depth equal 2" {
            {
                Get-ArubaCXRadiusServer -depth 2
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with depth equal 3" {
            {
                Get-ArubaCXRadiusServer -depth 3
            } | Should -Not -Throw
        }

        It "Get RADIUS Server with depth equal 4" {
            {
                Get-ArubaCXRadiusServer -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get RADIUS Server with one attribute (auth_type)" {
            $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -attribute auth_type
            @($radius).count | Should -Be 1
            $radius.address | Should -BeNullOrEmpty
            $radius.auth_type | Should -Not -BeNullOrEmpty
        }

        It "Get RADIUS Server with two attributes (auth_type, timeout)" {
            $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -attribute auth_type,timeout
            @($radius).count | Should -Be 1
            $radius.address | Should -BeNullOrEmpty
            $radius.auth_type | Should -Be "pap"
            $radius.timeout | Should -Be 15
        }

        It "Get RADIUS Server with three attributes (auth_type, timeout, retries)" {
            $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -attribute auth_type,timeout,retries
            @($radius).count | Should -Be 1
            $radius.address | Should -BeNullOrEmpty
            $radius.auth_type | Should -Be "pap"
            $radius.timeout | Should -Be 15
            $radius.retries | Should -Be 1
        }

    }

    Context "Search" {
        It "Search RADIUS Server by address ($pester_radius_address)" {
            $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
            @($radius).count | Should -Be 1
            $radius.address | Should -Be $pester_radius_address
            $radius.port | Should -Be $pester_radius_port
        }
    }

    AfterAll {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Remove-ArubaCXRadiusServer -confirm:$false
    }
}

Describe "Add RADIUS Server" {

    AfterEach {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Remove-ArubaCXRadiusServer -confirm:$false -ErrorAction SilentlyContinue
    }

    It "Add RADIUS Server $pester_radius_address (with only an address and a port, a group and a default priority for the group)" {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -depth 2
        $radius.address | Should -Be $pester_radius_address
        $radius.port | Should -Be $pester_radius_port
        $radius.group.radius | Should -Be "@{group_name=radius; group_type=radius; origin=built-in}"
        $radius.default_group_priority | Should -Be 1
        $radius.timeout | Should -Be $null
        $radius.passkey | Should -Be $null
        $radius.tracking_enable | Should -Be $false
    }

    It "Add RADIUS Server $pester_radius_address (with only an address and a port, a group and a default priority for the group, and a timeout)" {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1 -timeout 10
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -depth 2
        $radius.address | Should -Be $pester_radius_address
        $radius.port | Should -Be $pester_radius_port
        $radius.group.radius | Should -Be "@{group_name=radius; group_type=radius; origin=built-in}"
        $radius.default_group_priority | Should -Be 1
        $radius.timeout | Should -Be 10
        $radius.passkey | Should -Be $null
        $radius.tracking_enable | Should -Be $false
    }

    It "Add RADIUS Server $pester_radius_address (with only an address and a port, a group and a default priority for the group, a timeout, a passkey and tracking_enable)" {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1 -timeout 10 -passkey PowerArubaCX -tracking_enable
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -depth 2
        $radius.address | Should -Be $pester_radius_address
        $radius.port | Should -Be $pester_radius_port
        $radius.group.radius | Should -Be "@{group_name=radius; group_type=radius; origin=built-in}"
        $radius.default_group_priority | Should -Be 1
        $radius.timeout | Should -Be 10
        $radius.passkey | Should -Not -BeNullOrEmpty
        $radius.tracking_enable | Should -Be $true
    }

    It "Add RADIUS Server $pester_radius_address (with only an address and a port, a group and a default priority for the group, a timeout, a passkey, tracking_enable, and clearpass username)" {
        $password = ConvertTo-SecureString Example -AsPlainText -Force
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1 -timeout 10 -passkey PowerArubaCX -tracking_enable -cppm_user_id PowerArubaCX -cppm_password $password
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -depth 2
        $radius.address | Should -Be $pester_radius_address
        $radius.port | Should -Be $pester_radius_port
        $radius.group.radius | Should -Be "@{group_name=radius; group_type=radius; origin=built-in}"
        $radius.default_group_priority | Should -Be 1
        $radius.timeout | Should -Be 10
        $radius.passkey | Should -Not -BeNullOrEmpty
        $radius.tracking_enable | Should -Be $true
        $radius.clearpass.user_id | Should -Be "PowerArubaCX"
        $radius.clearpass.password | Should -Not -BeNullOrEmpty
    }
}

Describe "Configure RADIUS Server" {
    BeforeAll {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1
    }

    It "Change RADIUS Server default_group_priority" {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -default_group_priority 10
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.default_group_priority | Should -Be 10
    }

    It "Change RADIUS Server timeout" {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -timeout 10
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.timeout | Should -Be 10
    }

    It "Change RADIUS Server retries" {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -retries 1
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.retries | Should -Be 1
    }

    It "Change RADIUS Server tracking_enable (enable)" {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -tracking_enable:$true
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.tracking_enable | Should -Be $true
    }

    It "Change RADIUS Server tracking_enable (disable)" {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -tracking_enable:$false
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.tracking_enable | Should -Be $false
    }

    It "Change RADIUS ClearPass account" {
        $password = ConvertTo-SecureString Example -AsPlainText -Force
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Set-ArubaCXRadiusServer -cppm_user_id PowerArubaCX -cppm_password $password
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius.clearpass.user_id | Should -Be "PowerArubaCX"
        $radius.clearpass.password | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port | Remove-ArubaCXRadiusServer -confirm:$false
    }
}

Describe "Remove RADIUS Server" {

    BeforeEach {
        Add-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -group radius -default_group_priority 1
    }

    It "Remove RADIUS Server $pester_radius_address by address and port" {
        Remove-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port -confirm:$false
        $radius = Get-ArubaCXRadiusServer
        $radius.$pester_radius_address | Should -Be $NULL
    }

    It "Remove RADIUS Server $pester_radius_address by pipeline" {
        $radius = Get-ArubaCXRadiusServer -address $pester_radius_address -port $pester_radius_port
        $radius | Remove-ArubaCXRadiusServer -confirm:$false
        $radius = Get-ArubaCXRadiusServer
        $radius.$pester_radius_address | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false