#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2021, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Deploy-ArubaCXVm {

    <#
        .SYNOPSIS
        Deploy an Aruba CX OVA

        .DESCRIPTION
        Deploy a Virtual Machine Aruba CX on a vSphere environment with a lot of parameters like the choice of the cluster, the datastore, and the host....

        .EXAMPLE
        Deploy-ArubaCXVm -ovf_path "D:\ISO\CX\ArubaOS-CX_10_07_0004.ova" -vm_Host "host_Powerarubacx-01" -datastore "datastore_powerarubacx-01" -cluster "cluster_powerarubaCX-01" -name_vm "ArubaCX" -vmnetwork "CX - MGMT"

        This install your .ova on your vsphere with the host, the datastore, the cluster, the folder to place it and the name of your vm. It also configure your vm with a hostname, a network configuration, the network adapter and the port group of your vSwitch

        .EXAMPLE
        $cxBuildParams = @{
            ovf_path                    = "D:\ISO\CX\ArubaOS-CX_10_07_0004.ova"
            vm_host                     = "host_PowerarubaCX-01"
            datastore                   = "datastore_powerarubacx-01"
            cluster                     = "cluster_powerarubacx-01"
            inventory                   = "PowerArubaCX"
            name_vm                     = "ArubaCX"
            memoryGB                    = "4" #Default value
            cpu                         = "2" #Default value
            StartVM                     = $true
            vmnetwork                   = "CX - MGMT"
        }  # end $cxBuildParams

        PS>Deploy-ArubaCXVm @cxBuildParams

        Deploy Aruba CX VM by pass array with settings.
    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$ovf_path,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$vm_host,
        [Parameter (Mandatory = $true)]
        [string]$datastore,
        [Parameter (Mandatory = $true)]
        [string]$cluster,
        [Parameter (Mandatory = $false)]
        [string]$inventory,
        [Parameter (Mandatory = $true)]
        [string]$name_vm,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 32)]
        [int]$memoryGB,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 32)]
        [int]$cpu,
        [Parameter(Mandatory = $false)]
        [switch]$StartVM = $false,
        [Parameter (Mandatory = $true)]
        [string]$vmnetwork
    )

    Begin {
    }

    Process {

        #Check if VMWare PowerCLI is available (not use #Require because not mandatory module)
        if ($null -eq (Get-InstalledModule -name VMware.VimAutomation.Common -ErrorAction SilentlyContinue)) {
            Throw "You need to install VMware.PowerCLI (Install-Module VMware.PowerCLI)"
        }
        #Write-Warning "You need to have a vSwitch configured on your vSphere environment even if you use a DVS"
        #default vapp_config
        $vapp_config = @{
            "source" = $ovf_path
            "name"   = $name_vm
        }

        if ($DefaultVIServers.Count -eq 0) {
            throw "Need to be connect to vCenter (use Connect-VIServer)"
        }
        if (Get-VM $name_vm -ErrorAction "silentlyContinue") {
            Throw "VM $name_vm already exist, change name or remove VM"
        }

        if (-not (Get-Cluster -Name $cluster -ErrorAction "silentlycontinue")) {
            Throw "Cluster not found : $cluster"
        }
        else {
            $vapp_config.add("Location", $cluster)
        }

        if (-not (Get-VMHost -Name $vm_host -ErrorAction "silentlycontinue")) {
            Throw "Vm_Host not found : $vm_host"
        }
        else {
            $vapp_config.add("vmhost", $vm_host)
        }

        if (-not (Get-Datastore -Name $datastore -ErrorAction "silentlycontinue")) {
            Throw "Datastore not found : $datastore"
        }
        else {
            $vapp_config.add("datastore", $datastore)
        }

        if ( $PsBoundParameters.ContainsKey('inventory') ) {
            if (-not (Get-Inventory -Name $inventory -ErrorAction "silentlycontinue")) {
                Throw "Inventory not found : $inventory"
            }
            else {
                $vapp_config.add("inventory", $inventory)
            }
        }

        $ovfConfig = Get-OvfConfiguration -Ovf $ovf_path

        #Check if vSwitch is available ?
        $ovfConfig.NetworkMapping.Null.Value = $vmnetwork

        Import-VApp @vapp_config -OvfConfiguration $ovfConfig | Out-Null

        #Change memory (4 by default)
        if ( $PsBoundParameters.ContainsKey('MemoryGB') ) {
            Get-VM $name_vm | Set-VM -MemoryGB $MemoryGB -confirm:$false | Out-Null
        }

        #Change CPU (2 by default)
        if ( $PsBoundParameters.ContainsKey('CPU') ) {
            Get-VM $name_vm | Set-VM -NumCPU $cpu -confirm:$false | Out-Null
        }

        #Set NetworkAdapter to disable (for both/All...)
        Get-VM $name_vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected $false -Confirm:$false | Out-Null

        #Set NetworkAdapter 1 (OOBM MGMT) to enable
        Get-VM $name_vm | Get-NetworkAdapter -name "Network adapter 1" | Set-NetworkAdapter -StartConnected $true -Confirm:$false | Out-Null

        if ( $StartVM ) {
            Get-VM $name_vm | Start-VM | Out-Null
            Write-Output "$name_vm is started and ready to use"
        }
        else {
            Write-Output "$name_vm is ready to use (need to Start VM !)"
        }

    }

    End {
    }
}

function Set-ArubaCXVMFirtBootPassword {

    <#
        .SYNOPSIS
        Configure Password

        .DESCRIPTION
        Configure initial Password for Aruba CX OVA

        .EXAMPLE
        Set-ArubaCXVMFirtBootPassword -vmname ArubaCX -new_password MyNewPassword

        Configure password (using console) for the first connection

        .EXAMPLE
        $cxConfParams = @{
            vmname                  = "ArubaCX"
            new_password            = "MyNewPassword"
            write_memory            = $true
            exit                    = $true
        }
        PS>Set-ArubaCXVMFirtBootPassword @cxConfParams

        Configure password (using console) for the first connection, save configuration and exit
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    Param(
        [Parameter (Mandatory = $true)]
        [string]$vmname,
        [Parameter (Mandatory = $true)]
        [string]$new_password,
        [Parameter (Mandatory = $false)]
        [switch]$write_memory,
        [Parameter (Mandatory = $false)]
        [switch]$exit
    )

    Begin {
    }

    Process {
        if (-not (Get-Command -name Set-VMKeystrokes -ErrorAction SilentlyContinue)) {
            Throw "You need to install/import Set-VMKeystrokes script (Install-Script -Name VMKeystrokes)"
        }
        #Connection
        Set-VMKeystrokes -VMName $vmname -StringInput admin -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $vmname -SpecialKeyInput "KeyEnter"
        Start-Sleep 10

        #Change Password (First Connection)
        Set-VMKeystrokes -VMName $vmname -StringInput $new_password -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $vmname -StringInput $new_password -ReturnCarriage $true
        Start-Sleep 1

        #Save configuration
        if ( $PsBoundParameters.ContainsKey('write_memory') ) {
            if ( $write_memory ) {
                Set-VMKeystrokes -VMName $vmname -StringInput "write memory" -ReturnCarriage $true
                Start-Sleep 2
            }
        }

        #Exit ?
        if ( $PsBoundParameters.ContainsKey('exit') ) {
            if ( $exit ) {
                Set-VMKeystrokes -VMName $vmname -StringInput "exit" -ReturnCarriage $true
                Start-Sleep 1
            }
        }
    }

    End {
    }
}

function Set-ArubaCXVMMgmtOobm {

    <#
        .SYNOPSIS
        Configure MGMT Interface

        .DESCRIPTION
        Configure IP Address on OOBM Interface

        .EXAMPLE
        Set-VMArubaCXMgmtOob -vmname ArubaCX -mgmt_ip 192.0.2.1 -mgmt_mask 24

        Configure IP Address 192.0.2.1(/24) to mgmt interface of Aruba CX OVA

        .EXAMPLE
        $cxConfMgmtParams = @{
            vmname                  = "ArubaCX"
            password                = "MyPassword"
            mgmt_ip                 = "192.0.2.1"
            mgmt_mask               = "24"
            mgmt_gateway            = "192.0.2.254"
            write_memory            = $true
            exit                    = $true
        }
        Set-ArubaCXVMMgmtOobm @cxConfMgmtParams

        Configure IP Address 192.0.2.1(/24)  with gateway to mgmt interface of Aruba CX OVA
        Also reconnect to the switch and save the configuration and exit!
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    Param(
        [Parameter (Mandatory = $true)]
        [string]$vmname,
        [Parameter (Mandatory = $false)]
        [string]$password,
        [Parameter (Mandatory = $false)]
        [switch]$write_memory,
        [Parameter (Mandatory = $false)]
        [switch]$exit,
        [Parameter (Mandatory = $true)]
        [ipaddress]$mgmt_ip,
        [Parameter (Mandatory = $true)]
        [ValidateRange(0, 32)]
        [int]$mgmt_mask,
        [Parameter (Mandatory = $false)]
        [ipaddress]$mgmt_gateway
    )

    Begin {
    }

    Process {

        if (-not (Get-Command -name Set-VMKeystrokes -ErrorAction SilentlyContinue)) {
            Throw "You need to install/import Set-VMKeystrokes script (Install-Script -Name VMKeystrokes)"
        }

        #Connection ?
        if ( $PsBoundParameters.ContainsKey('password') ) {

            Set-VMKeystrokes -VMName $vmname -StringInput admin -ReturnCarriage $true
            Start-Sleep 1
            Set-VMKeystrokes -VMName $vmname -StringInput $password -ReturnCarriage $true
            Start-Sleep 5
        }

        Set-VMKeystrokes -VMName $vmname -StringInput "conf t" -ReturnCarriage $true
        Start-Sleep 1

        #Configuration OOBM (mgmt) interface
        Set-VMKeystrokes -VMName $vmname -StringInput "interface mgmt" -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $vmname -StringInput "no shutdown" -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $vmname -StringInput "ip static $mgmt_ip/$mgmt_mask" -ReturnCarriage $true
        Start-Sleep 1
        if ( $PsBoundParameters.ContainsKey('mgmt_gateway') ) {
            Set-VMKeystrokes -VMName $vmname -StringInput "default-gateway $mgmt_gateway" -ReturnCarriage $true
            Start-Sleep 1
        }
        #Exit Configure interface mgmt context
        Set-VMKeystrokes -VMName $vmname -StringInput "exit" -ReturnCarriage $true
        Start-Sleep 1
        #Exit Configure terminal (conf t mode)
        Set-VMKeystrokes -VMName $vmname -StringInput "exit" -ReturnCarriage $true
        Start-Sleep 1

        #Save configuration
        if ( $PsBoundParameters.ContainsKey('write_memory') ) {
            if ( $write_memory ) {
                Set-VMKeystrokes -VMName $vmname -StringInput "write memory" -ReturnCarriage $true
                Start-Sleep 2
            }
        }

        #Exit ?
        if ( $PsBoundParameters.ContainsKey('exit') ) {
            if ( $exit ) {
                Set-VMKeystrokes -VMName $vmname -StringInput "exit" -ReturnCarriage $true
                Start-Sleep 1
            }
        }
    }

    End {
    }
}