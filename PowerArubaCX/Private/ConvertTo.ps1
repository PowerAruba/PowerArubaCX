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

function ConvertTo-ArubaCXARPTable {

    <#
      .SYNOPSIS
      ConvertTo Aruba CX ARP Table

      .DESCRIPTION
      Convert ArubaCX ARP Table to more easy array (with mac, IP, vlan and port)

      .EXAMPLE
      Get-ArubaCXNeighbors -depth 2 | ConvertTo-ArubaCXARPTable

      Convert ArubaCX Neighbors to ARP Table (mac, IP? vlan and port)
    #>

    Param(
        [Parameter(Mandatory = $true, position = 1, ValueFromPipeline = $true)]
        [PSObject]$arp
    )

    Begin {
    }

    Process {
        $table = @()

        #Get list of vrf name
        $list_arp_vrf_name = $arp.psobject.properties.name

        foreach ($arp_vrf_name in $list_arp_vrf_name) {
            $list_arp = $arp.$arp_vrf_name

            #get List of arp name (IP + Vlan...)
            $list_arp_name = $list_arp.psobject.properties.name

            foreach ($arp_name in $list_arp_name) {
                $ipvlan = $arp.$arp_vrf_name.$arp_name
                $table += [pscustomobject]@{
                    "ip_address" = $ipvlan.ip_address
                    "mac"        = $ipvlan.mac
                    "vlan"       = $ipvlan.port.psobject.properties.name
                    "port"       = $ipvlan.phy_port.psobject.properties.name
                    "vrf"        = $arp_vrf_name
                }
            }
        }
        $table
    }

    End {
    }

}