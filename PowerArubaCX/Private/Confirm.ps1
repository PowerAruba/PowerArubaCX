#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Confirm-ArubaCXVlan {

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
