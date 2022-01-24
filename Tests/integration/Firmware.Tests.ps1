#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCX @invokeParams
}

#Only Basic check because no neighbor... (need to add some peer switch)
Describe "Get Firmware" {

    It "Get Firmware Does not throw an error" {
        {
            Get-ArubaCXFirmware
        } | Should -Not -Throw
    }

    It "Get Firmware Status Does not throw an error" {
        {
            Get-ArubaCXFirmware -status
        } | Should -Not -Throw
    }
}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}