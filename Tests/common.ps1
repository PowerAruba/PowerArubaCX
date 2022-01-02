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
$script:pester_interface2 = "1/1/2" #interface id for test...
$script:pester_lag = "2" #lag id for test...
$script:pester_vrf = "pester_vrf" #interface id for test...

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...

$script:mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force

$script:invokeParams = @{
    server               = $ipaddress;
    username             = $login;
    password             = $mysecpassword;
    port                 = $port;
    SkipCertificateCheck = $true;
}

if ($null -eq $port) {
    $invokeParams.port = 443
}