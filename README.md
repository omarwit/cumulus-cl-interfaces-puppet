# cumulus_interface

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with [cumulus_interface]](#setup)
    * [What `cumulus_interface` affects](#what-cumulus_interface-affects)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module provides 3 resource types that can configure
most types of interfaces available on Cumulus Linux.

## Module Description

The module consists of 3 resources types

* **cumulus_interface**
Manage a network interface using the ifupdown2 toolkit. The configuration for the interface will be written to a fragment under the interface configurations fragments directory. Does not configure vxlan, bond or bridge interfaces. For bridge configuration use the `cumulus_bridge` module. For bond configuration use the `cumulus_bond` module.

* **cumulus_bond**
Manage a network bond using the ifupdown2 toolkit. The configuration for the interface will be written to a fragment under the interface configurations fragments directory.

* **cumulus_bridge**
Manage a bridge using the ifupdown2 toolkit. The configuration for the interface will be written to a fragment under the interface configurations
fragments directory.

## Setup

### What cumulus_interface affects

* This module affects the configuration files located in the interfaces folder defined by ifupdown2..
By default this is `/etc/network/interfaces.d`.

* To activate the changes run `service networking reload`.
> **NOTE**: reloading interface config will not be disruptive if there is no
> change in the configuration.


## Usage

**cumulus_interface Examples:**

Configure the loopback interface and the management interface `eth0` using DHCP:

```ruby
cumulus_interface { 'lo':
  addr_method => 'loopback'
}

cumulus_interface { 'eth0':
  addr_method  => 'dhcp'
}
```

Configure `swp33` as a 1GbE port with a single IPv4 address:

```ruby
cumulus_interface { 'swp33':
  ipv4 => ['10.30.1.1/24']
  speed => 1000
end
```

Configure the interface `peerlink.4094` as the CLAG peer interface:

```ruby
cumulus_interface { 'peerlink.4094':
  ipv4 => ['10.100.1.0/31']
  clagd_enable => true
  clagd_peer_ip => '10.100.1.1/31'
  clagd_sys_mac => '44:38:39:ff:20:94'
}
```

**cumulus_bond Examples:**

Create a bond called `peerlink` with the interfaces `swp1` and `swp2` as
members:

```ruby
cumulus_bond { 'peerlink':
  slaves => ['swp1-2']
}
```

Create a bond called `bond0` with the interfaces `swp3` and `swp4` as members,
using layer2+3 TX hashing and the CLAG ID set:

```ruby
cumulus_bond { 'bond0':
  slaves => ['swp3-4']
  xmit_hash_policy => 'layer2+3'
  clag_id => 1
}
```

**cumulus_bridge Examples:**

"Classic" bridge driver:

```ruby
cumulus_bridge { 'br10':
  ports      => ['swp11-12.1', 'swp32.1']
  ipv4       => ['10.1.1.1/24', '10.20.1.1/24']
  ipv6       => ['2001:db8:abcd::/48']
  alias_name =>  'classic bridge'
  mtu        => 9000
  mstpctl_treeprio =>  4096
}
```

VLAN aware bridge:

```ruby
cumulus_bridge { 'bridge':
  vlan_aware => true
  ports      => ['peerlink', 'downlink', 'swp10']
  vids       => ['1-4094']
  pvid       => 1
  stp        => true
  mstpctl_treeprio  => 4096
}
```

## Reference


## Limitations

This module only works on Cumulus Linux.

The ``puppet resource`` command for `cumulus_interface`, `cumulus_bond` and
`cumulus_bridge` is currently not supported. It may be added in a future release.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.

## Cumulus Linux

![Cumulus Networks Icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

Cumulus Linux is a software distribution that runs on top of industry standard
networking hardware. It enables the latest Linux applications and automation
tools on networking gear while delivering new levels of innovation and
ﬂexibility to the data center.

For further details please see: [http://cumulusnetworks.com](http://www.cumulusnetworks.com)
