#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1


Describe  "Connect to a switch (using HTTPS)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCX -noconfirm
    }
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" {
        Connect-ArubaCX $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
        $DefaultArubaCXConnection | Should Not BeNullOrEmpty
        $DefaultArubaCXConnection.server | Should be $ipaddress
        $DefaultArubaCXConnection.httpOnly | Should be $false
        $DefaultArubaCXConnection.session | Should not BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" {
        Disconnect-ArubaCX -noconfirm
        $DefaultArubaCXConnection | Should be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:("Desktop" -eq $PSEdition) {
        { Connect-ArubaCX $ipaddress -Username $login -password $mysecpassword } | Should throw "Unable to connect (certificate)"
    }
}