#
# Copyright 2024, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function ConvertTo-ArubaCXMacAddressTable {

    <#
      .SYNOPSIS
      ConvertTo Aruba CX Mac Address Table

      .DESCRIPTION
      Convert ArubaCX Macs Address Table to more easy array (with mac, vlan and port)


      .EXAMPLE
      Get-ArubaCXMacs -depth 2 | ConvertTo-ArubaCXMacAddressTable

      Convert ArubaCX Macs to MAC Address Table (mac, vlan and port)
    #>

    Param(
        [Parameter(Mandatory = $true, position = 1, ValueFromPipeline = $true)]
        [PSObject]$mac
    )

    Begin {
    }

    Process {
        $table = @()
        #Get list of vlan name
        $list_mac_vlan_name = $mac.psobject.properties.name

        foreach ($mac_vlan_name in $list_mac_vlan_name) {
            $list_mac = $mac.$mac_vlan_name
            $list_mac_name = $list_mac.psobject.properties.name

            #get List of modemac (Dynamic + MAC @)
            foreach ($mac_name in $list_mac_name) {
                $modemac = $mac.$mac_vlan_name.$mac_name
                $table += [pscustomobject]@{
                    "mac"  = $modemac.mac_addr
                    "vlan" = $mac_vlan_name
                    "port" = $modemac.port.psobject.properties.name
                }
            }
        }

        $table
    }

    End {
    }

}
