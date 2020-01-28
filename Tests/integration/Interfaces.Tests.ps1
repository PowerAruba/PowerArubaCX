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

    It "Get Interface (1/1/1)" {
        $int = Get-ArubaCXInterfaces | Where-Object { $_.name -eq "pester_SW1" }
        $int.id | Should not be BeNullOrEmpty
        $int.name | Should be "1/1/1"
    }

    # It "Get Interface (1/1/1) and confirm (via Confirm-ArubaCXInterface)" {
    #     $int = Get-ArubaCXInterfaces | Where-Object { $_.name -eq "pester_SW1" }
    #     Confirm-ArubaCXInterfaces $int | Should be $true
    # }

    It "Search Interface by name (1/1/1)" {
        $int = Get-ArubaCXInterfaces -name 1/1/1
        @($int).count | Should be 1
        $int.name | Should be "1/1/1"
    }
}

Describe  "Configure Interface" {
    BeforeAll {
        #Make a CheckPoint ?
    }

    It "Change interface description" {
        Set-ArubaCXInterfaces -name 1/1/1 -description "Modified by PowerArubaCX"
        $int = Get-ArubaCXInterfaces -name 1/1/1
        $int.name | Should be "1/1/1"
        $int.description | Should be "Modified by PowerArubaCX"
    }

    It "Change interface status (up)" {
        Set-ArubaCXInterfaces -name 1/1/1 -status up
        $int = Get-ArubaCXInterfaces -name 1/1/1
        $int.user_config.admin | Should be "up"
    }

    It "Change interface status (down)" {
        Set-ArubaCXInterfaces -name 1/1/1 -status down
        $int = Get-ArubaCXInterfaces -name 1/1/1
        $int.user_config.admin | Should be "down"
    }

    It "Change interface routing (disable)" {
        Set-ArubaCXInterfaces -name 1/1/1 -routing:$false
        $int = Get-ArubaCXInterfaces -name 1/1/1
        $int.routing | Should be $false
    }

    It "Change interface routing (enable)" {
        Set-ArubaCXInterfaces -name 1/1/1 -routing:$true
        $int = Get-ArubaCXInterfaces -name 1/1/1
        $int.routing | Should be $true
    }

    AfterAll {
        #Reverse CheckPoint ?
    }
}

Disconnect-ArubaCX -noconfirm