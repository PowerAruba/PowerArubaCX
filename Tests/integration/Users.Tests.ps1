#
# Copyright 2022, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCX @invokeParams
}

Describe "Get Users" {
    It "Get Users Does Not Throw an error" {
        {
            Get-ArubaCXUsers
        } | Should -Not -Throw
    }

    #It "Get Users (admin) and confirm (via Confirm-ArubaCXUsers)" {
    #    $user = Get-ArubaCXUsers -user admin
    #    Confirm-ArubaCXUsers ($user) | Should -Be $true
    #}

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Users with selector equal configuration" {
            {
                Get-ArubaCXUsers -selector configuration
            } | Should -Not -Throw
        }

        It "Get Users with selector equal statistics" {
            {
                Get-ArubaCXUsers -selector statistics
            } | Should -Not -Throw
        }

        It "Get Users with selector equal status" {
            {
                Get-ArubaCXUsers -selector status
            } | Should -Not -Throw
        }

        It "Get Users with selector equal writable" {
            {
                Get-ArubaCXUsers -user admin -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get Users with depth equal 1" {
            {
                Get-ArubaCXUsers -depth 1
            } | Should -Not -Throw
        }

        It "Get Users with depth equal 2" {
            {
                Get-ArubaCXUsers -depth 2
            } | Should -Not -Throw
        }

        It "Get Users with depth equal 3" {
            {
                Get-ArubaCXUsers -depth 3
            } | Should -Not -Throw
        }
        It "Get Users with depth equal 4" {
            {
                Get-ArubaCXUsers -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get Users with one attribute (name)" {
            $user = Get-ArubaCXUsers -user admin -attribute name
            $user.name | Should -Not -BeNullOrEmpty
            $user.origin | Should -BeNullOrEmpty
        }

        It "Get Users with two attributes (name, origin)" {
            $user = Get-ArubaCXUsers -user admin -attribute name, origin
            $user.name | Should -Not -BeNullOrEmpty
            $user.origin | Should -Not -BeNullOrEmpty
        }
    }

    Context "Search" {

        It "Search Users by user (admin)" {
            $user = Get-ArubaCXUsers -user admin
            @($user).count | Should -Be 1
            $user.name | Should -Be "admin"
        }

        It "Search Users by user (using position) (admin)" {
            $user = Get-ArubaCXUsers admin
            @($user).count | Should -Be 1
            $user.name | Should -Be "admin"
        }
    }

}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}