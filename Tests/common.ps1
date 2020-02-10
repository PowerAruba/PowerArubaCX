#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
Param()
# default settings for test...
$script:pester_vlan = 85 #vlan id for Vlan test (and Port Test)
$script:pester_interface = "1/1/1" #interface id for test...

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...


$script:mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force

Connect-ArubaCX -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
