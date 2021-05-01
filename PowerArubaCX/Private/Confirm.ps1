#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Confirm-ArubaCXInterfaces {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )
    #Check if it looks like an Interface element

    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name admin -Membertype Properties)) {
        throw "Element specified does not contain a admin_state property."
    }
    if ( -not ( $argument | get-member -name routing -Membertype Properties)) {
        throw "Element specified does not contain a routing property."
    }
    if ( -not ( $argument | get-member -name vrf -Membertype Properties)) {
        throw "Element specified does not contain a vrf property."
    }
    if ( -not ( $argument | get-member -name vlan_mode -Membertype Properties)) {
        throw "Element specified does not contain a vlan_mode property."
    }
    $true

}
function Confirm-ArubaCXSystem {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )
    #Check if it looks like an System element

    if ( -not ( $argument | get-member -name hostname -Membertype Properties)) {
        throw "Element specified does not contain a hostname property."
    }
    if ( -not ( $argument | get-member -name other_config -Membertype Properties)) {
        throw "Element specified does not contain an other_config property."
    }
    if ( -not ( $argument | get-member -name timezone -Membertype Properties)) {
        throw "Element specified does not contain a timezone property."
    }
    if ( -not ( $argument | get-member -name rest_api -Membertype Properties)) {
        throw "Element specified does not contain a rest_api property."
    }
    if ( -not ( $argument | get-member -name mgmt_intf -Membertype Properties)) {
        throw "Element specified does not contain a mgmt_intf property."
    }
    if ( -not ( $argument | get-member -name aaa -Membertype Properties)) {
        throw "Element specified does not contain an aaa property."
    }
    $true

}

function Confirm-ArubaCXVlans {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )
    #Check if it looks like an Vlan element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name admin -Membertype Properties)) {
        throw "Element specified does not contain a admin property."
    }
    if ( -not ( $argument | get-member -name voice -Membertype Properties)) {
        throw "Element specified does not contain a voice property."
    }
    if ( -not ( $argument | get-member -name type -Membertype Properties)) {
        throw "Element specified does not contain a type property."
    }
    if ( -not ( $argument | get-member -name description -Membertype Properties)) {
        throw "Element specified does not contain a description property."
    }
    $true
}

function Confirm-ArubaCXVrfs {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )
    #Check if it looks like an VRF element

    if ( -not ( $argument | get-member -name rd -Membertype Properties)) {
        throw "Element specified does not contain a rd property."
    }
    if ( -not ( $argument | get-member -name https_server -Membertype Properties)) {
        throw "Element specified does not contain a https_server property."
    }
    if ( -not ( $argument | get-member -name snmp_enable -Membertype Properties)) {
        throw "Element specified does not contain a snmp_enable property."
    }
    if ( -not ( $argument | get-member -name source_interface -Membertype Properties)) {
        throw "Element specified does not contain a source_interface property."
    }
    if ( -not ( $argument | get-member -name source_ip -Membertype Properties)) {
        throw "Element specified does not contain a source_ip property."
    }
    if ( -not ( $argument | get-member -name ssh_enable -Membertype Properties)) {
        throw "Element specified does not contain a ssh_enable property."
    }
    $true
}