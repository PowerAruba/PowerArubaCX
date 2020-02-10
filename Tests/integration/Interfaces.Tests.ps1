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

    It "Get ALL Interface" {
        $int = Get-ArubaCXInterfaces
        $int.count | Should not be $NULL
    }

    It "Get Interface ($pester_interface) and confirm (via Confirm-ArubaCXInterface)" {
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        Confirm-ArubaCXInterface $int | Should be $true
    }

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

Describe  "Configure Interface" {
    BeforeAll {
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
        #Reverse CheckPoint ?
    }
}

Disconnect-ArubaCX -noconfirm