#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
Param()
# default settings for test...
$script:pester_vlan = 85 #vlan id for Vlan test
$script:pester_vlan2 = 86 #vlan id for Vlan test (for affect a second vlan to interface)
$script:pester_interface = "1/1/1" #interface id for test...
$script:pester_vrf = "pester_vrf" #interface id for test...
$script:pester_tacacs_address = "192.2.0.1"
$script:pester_tacacs_port = "49"
$script:pester_radius_address = "192.2.0.1"
$script:pester_radius_port = "1812"
$script:pester_radius_group = "PowerArubaCX"

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...


$script:mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force

Connect-ArubaCX -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
