# Cumulus Interface Module

License: GPLv2

## Work in Progress

#### Table of Contents

- [Cumulus Interface module](#cumulus-interface-module)
  - [Overview](#overview)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Reference](#reference)
  - [Contributors](#contributors)
  - [Development](#development)
  - [Testing](#testing)

## Overview

This module can configure a variety of interfaces on Cumulus Linux

## Features

The module configures the following interface types
* physical ports (swpX) or (swpXsY)
* SVI interface. These are subinterfaces of bridge interfaces running in vlan
  aware mode
* Layer3 subinterfaces of physical ports or bonds.
* Management Ports, e.g eth0
* Loopback interface

To configure bonds or bridges, use the cumulus_bond or cumulus_bridge puppet
modules.


Interface configuration is performed by ifupdown2 which has the ability to place
each interface configuration in a separate file. This module assumes that the
switch has a /etc/network/interfaces that looks like this
```
# Managed by Puppet
source /etc/network/interfaces.d/*
```
Then interface configuration can be found in files located in
`/etc/network/interfaces.d/`

```
cumulus# tree /etc/network/interfaces.d
/etc/network/interfaces.d
├── bond0
├── eth0
├── lo
├── swp1
└── swp2
```

This module can apply commonly used features the interface types described above
such as ip address, mtu, and speed. For a full list of options see the `Usage`
section.

`service networking reload` will unconfigure any interface from the kernel that is
not defined ifupdown2.

## Setup


## Usage

## Reference

    ```

  * `allowed` : Required option. This option must be an array. It lists all the interfaces that can be configured on the switch. Range of interface are allowed.
    ```
    allowed => ['lo', eth0', 'swp1-30', 'bond0-20']
    ```


  * `location`: where interface files are stored. By default this is /etc/network/interfaces.d.
`/etc/network/interfaces` must be configured with the following 2 lines
    ```
    #Managed By Puppet
    source /etc/network/interfaces.d/
    ```

## Limitations

This module only works on Cumulus Linux.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.


![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

### Cumulus Linux

Cumulus Linux is a software distribution that runs on top of industry standard
networking hardware. It enables the latest Linux applications and automation
tools on networking gear while delivering new levels of innovation and
ﬂexibility to the data center.

For further details please see:
[cumulusnetworks.com](http://www.cumulusnetworks.com)

## CONTRIBUTORS

- Stanley Karunditu (@skamithik)
