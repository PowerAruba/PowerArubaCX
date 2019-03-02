# PowerArubaCX

This is a Powershell module for configure a ArubaOS Switch.

With this module (version 0.1) you can manage:

- Invoke API using Invoke-ArubaCXRestMethod

More functionality will be added later.

Tested with ArubaCX 8400 and 8320 (using 10.x firmware)

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE.
<!--
For example, you can manage Vlans with the following commands:
- `Get-ArubaCXVlans`
- `Add-ArubaCXVlans`
- `Set-ArubaCXVlans`
- `Remove-ArubaCXVlans`
-->

# Requirements

- Powershell 5 (If possible get the latest version)
- An ArubaCX Switch (with firmware 10.x) and REST API enable

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5):
    Install-Module PowerArubaCX

# Import the module
    Import-Module PowerArubaCX

# Get commands in the module
    Get-Command -Module PowerArubaCX

# Get help
    Get-Help Invoke-ArubaCXRestMethod -Full
```

# Examples
### Connecting to the Aruba Switch

The first thing to do is to connect to a Aruba Switch with the command `Connect-ArubaCX`:

```powershell
# Connect to the Aruba CX Switch
    Connect-ArubaCX 192.0.2.1

#we get a prompt for credential
```

<!--
### Vlans Management

You can create a new Vlan `Add-ArubaSWVlans`, retrieve its information `Get-ArubaSWVlans`, modify its properties `Set-ArubaSWVLans`, or delete it `Remove-ArubaSWVlans`.

```powershell
# Create a vlan
    Add-ArubaSWVlans -id 85 -Name 'PowerArubaSW' -is_voice_enabled

    uri               : /vlans/85
    vlan_id           : 85
    name              : PowerArubaSW
    status            : VS_PORT_BASED
    type              : VT_STATIC
    is_voice_enabled  : False
    is_jumbo_enabled  : True
    is_dsnoop_enabled : False


# Get information about vlan
    Get-ArubaSWVlans -name PowerArubaSW | ft

    uri       vlan_id name         status        type      is_voice_enabled is_jumbo_enabled is_dsnoop_enabled is_management_vlan
    ---       ------- ----         ------        ----      ---------------- ---------------- ----------------- ------------------
    /vlans/85      85 PowerArubaSW VS_PORT_BASED VT_STATIC            False             True             False              False


# Remove a vlan
    Remove-ArubaSWVlans -id 85
```
-->
### Invoke API
for example to get ClearPass version

```powershell
# get Aruba CX System Configuration using API
    Invoke-ArubaCXRestMethod -method "get" -uri "rest/v1/system?selector=configuration"

    app_major_version   : 6

[...]
```
to get API uri, go to ClearPass Swagger (https://ArubaCX-IP/api)
![](./Medias/ArubaCX_API.png)

And choice a service (for example System)
![](./Medias/ArubaCX_API_system.png)

### Disconnecting

```powershell
# Disconnect from the Aruba CX Switch
    Disconnect-ArubaCX
```


# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2018 Alexis La Goutte and the community.
