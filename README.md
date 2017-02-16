[![Build Status](https://travis-ci.org/icann-dns/puppet-nsd.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-nsd)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/nsd.svg?maxAge=2592000)](https://forge.puppet.com/icann/nsd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/nsd.svg?maxAge=2592000)](https://forge.puppet.com/icann/nsd)
# nsd

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with nsd](#setup)
    * [What nsd affects](#what-nsd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with nsd](#beginning-with-nsd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage the installation and configuration of NSD (name serve daemon) and zone files.

## Module Description

This module allows for the management of all aspects of the NSD configuration 
file, keys and zonefiles.  

## Setup

### What nsd affects

* Manages configuration the nsd configueration file 
* Manages zone data in the zone dir
* dynamicly sets processor count based on installed processes
* can manage nsd control

### Setup Requirements **OPTIONAL**

* depends on stdlib 4.11.0 (may work with earlier versions)

### Beginning with nsd

Install the package an make sure it is enabled and running with default options:

```puppet 
class { '::nsd': }
```

With some basic configueration

```puppet
class { '::nsd':
  ip_addresses => ['192.0.2.1'],
  rrl_size     => 1000,
}
```

and in hiera

```yaml
nsd::ip_addresses:
- 192.0.2.1
rrl_size: 1000
```

## Usage

Add config with tsig key

```puppet
class {'::nsd': 
  tsig => {
    'name' => 'test',
    'algo' => 'hmac-sha256',
    'data' => 'adsasdasdasd='
  }
}
```

or with hiera

```yaml
nsd::tsig:
  name: test
  algo: hmac-sha256
  data: adsasdasdasd=
```

add zone files.  zone files are added with sets of common config.

```puppet
class {'::nsd': 
  zones => {
    'master1_zones' => {
      'allow_notify' => ['192.0.2.1'],
      'masters'      => ['192.0.2.1'],
      'provide_xfr'  => ['127.0.0.1'],
      'zones'        => ['example.com', 'example.net']
    },
    'master2_zones'  => {
      'allow_notify' => ['192.0.2.2'],
      'masters'      => ['192.0.2.2'],
      'provide_xfr'  => ['127.0.0.2'],
      'zones'        => ['example.org']
    }
  }
}
```

in hiera

```yaml
nsd::zones:
  master1_zones:
    allow_notify:
    - 192.0.2.1
    masters:
    - 192.0.2.1
    provide_xfr:
    - 192.0.2.1
    zones:
    - example.com
    - example.net
  master2_zones:
    allow_notify:
    - 192.0.2.2
    masters:
    - 192.0.2.2
    provide_xfr:
    - 192.0.2.2
    zones:
    - example.org
```

creat and as112 server also uses the nsd::file resource

```puppet
  class {'::nsd': }
  nsd::zone {
    'rfc1918': 
      'zonefile' => 'db.dd-empty',
      'zones' => [
        '10.in-addr.arpa',
        '16.172.in-addr.arpa',
        '17.172.in-addr.arpa',
        '18.172.in-addr.arpa',
        '19.172.in-addr.arpa',
        '20.172.in-addr.arpa',
        '21.172.in-addr.arpa',
        '22.172.in-addr.arpa',
        '23.172.in-addr.arpa',
        '24.172.in-addr.arpa',
        '25.172.in-addr.arpa',
        '26.172.in-addr.arpa',
        '27.172.in-addr.arpa',
        '28.172.in-addr.arpa',
        '29.172.in-addr.arpa',
        '30.172.in-addr.arpa',
        '31.172.in-addr.arpa',
        '168.192.in-addr.arpa',
        '254.169.in-addr.arpa'
      ];
    'empty.as112.arpa':
      'zonefile' => 'db.dr-empty',
      'zones'    => ['empty.as112.arpa'];
    'hostname.as112.net':
      'zonefile' => 'hostname.as112.net.zone',
      'zones'    =>  ['hostname.as112.net'];
    'hostname.as112.arpa':
      'zonefile' => 'hostname.as112.arpa.zone',
      'zones'    => ['hostname.as112.arpa'];
  }
  nsd::file {
    'db.dd-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dd-empty';
    'db.dr-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dr-empty';
    'hostname.as112.net.zone':
      content_template => 'nsd/etc/nsd/hostname.as112.net.zone.erb';
    'hostname.as112.arpa.zone':
      content_template => 'nsd/etc/nsd/hostname.as112.arpa.zone.erb';
  }
```

```yaml
nsd::files:
  db.dd-empty:
    source: 'puppet:///modules/nsd/etc/nsd/db.dd-empty'
  db.dr-empty:
    source: 'puppet:///modules/nsd/etc/nsd/db.dr-empty'
  hostname.as112.net.zone:
    content_template: 'nsd/etc/nsd/hostname.as112.net.zone.erb'
  hostname.as112.arpa.zone:
    content_template: 'nsd/etc/nsd/hostname.as112.arpa.zone.erb'
nsd::zones:
  rfc1918:
    zonefile: db.dd-empty
    zones:
    - 10.in-addr.arpa
    - 16.172.in-addr.arpa
    - 17.172.in-addr.arpa
    - 18.172.in-addr.arpa
    - 19.172.in-addr.arpa
    - 20.172.in-addr.arpa
    - 21.172.in-addr.arpa
    - 22.172.in-addr.arpa
    - 23.172.in-addr.arpa
    - 24.172.in-addr.arpa
    - 25.172.in-addr.arpa
    - 26.172.in-addr.arpa
    - 27.172.in-addr.arpa
    - 28.172.in-addr.arpa
    - 29.172.in-addr.arpa
    - 30.172.in-addr.arpa
    - 31.172.in-addr.arpa
    - 168.192.in-addr.arpa
    - 254.169.in-addr.arpa
  'empty.as112.arpa':
    zonefile: db.dr-empty
    zones:
    - empty.as112.arpa
  'hostname.as112.net':
    zonefile: hostname.as112.net.zone
    zones:
    - hostname.as112.net
  'hostname.as112.arpa':
    zonefile: hostname.as112.arpa.zone
    zones:
    - hostname.as112.arpa
```

## Reference


- [**Public Classes**](#public-classes)
    - [`nsd`](#class-nsd)
- [**Private Classes**](#private-classes)
    - [`nsd::params`](#class-nsdparams)
- [**Private defined types**](#private-defined-types)
    - [`nsd::file`](#defined-nsdfile)
    - [`nsd::tsig`](#defined-nsdtsig)
    - [`nsd::zone`](#defined-nsdzone)
- [**Facts**](#facts)
    - ['nsd_version'](#fact-nsdversion)

### Classes

### Public Classes

#### Class: `nsd`
  Guides the basic setup and installation of NSD on your system
  
##### Parameters (all optional)

* `enable` (Bool, Default: true): enable or disable the nsd service, config files are still configuered.
* `tsig`: legacy parameter to pass tsig via hash { name => '', algo => '', data => '' } use nsd::tsig or nsd::tsigs instead
* `slave_addresses` (Hash, Default: {}): a hash key value pairs representing ip address tsig key name values.  e.g. { '192.0.2.1' : 'tsig-key' }.
* `zones`: a hash which is passed to create_resoure(nsd::zone, $zones). Default: Empty.
* `files` (Hash, Default: {}):  a hash which is passed to create_resoure(nsd::file, $files).
* `tsigs` (Hash, Default: {}): a hash which is passed to create_resoure(nsd::tsig, $tsigs)
* `logrotate_rotate` (Integer, Default: 5): The number of rotated log files to keep on disk.
* `logrotate_size` (String, Default: 100M): The String size a log file has to reach before it will be rotated.  The default units are bytes, append k, M or G for kilobytes, megabytes or gigabytes respectively.
* `master` (Bool, Default: false: Specify if the server is a master or slave.
* `server_template` (File Path, Default: 'nsd/etc/nsd/nsd.server.conf.'): template file to use for server config.  only change if you know what you are doing.
* `zones_template` (File Path, Default: 'nsd/etc/nsd/nsd.zones.conf.erb'): template file to use for zone config.  only change if you know what you are doing.
* `ip_addresses` (Array, Default: []): Array of IP addresses to listen on.
* `ip_transparent` (Bool, Default: false): Allows NSD to bind to non local addresses.  This is useful to have NSD listen to IP addresses that are not (yet) added to the network interface, so that it can answer immediately when the address is added.
* `identity` (String, Default: $::fqdn): A string to specify the identity when asked for CH TXT ID.SERVER
* `nsid` (String, Default: $::fqdn): A string representing the nsid to add to the EDNS section of the answer when queried with an NSID EDNS enabled packet.
* `logfile` (File Path, Default: undef): A string to specify the logfile to use.
* `server_count (Integer. Default: if $::processorcount < 4 otherwise $::processorcount - 3)`:  Start this many NSD servers.
* `tcp_count` (Integer, Default: 250):  The maximum number of concurrent, active TCP connections by each server. valid options: Integer.
* `tcp-query-count` (Integer, Default: 0 (unlimited): The maximum number of queries served on a single TCP connection.
* `tcp-timeout` (Integer, Default: undef):  Overrides the default TCP timeout.
* `ipv4_edns_size` (Integer < 4097, Default: 4096): Preferred EDNS buffer size for IPv4.
* `ipv6_edns_size` (Integer < 4097, Default: 4096): Preferred EDNS buffer size for IPv6.
* `pidfile` (File Path, Default: OS Specific): Use the pid file.
* `port` (Integer < 65536, Default: 53): Port to listen on.
* `statistics` (Integer, Default: undef): If not present no statistics are dumped. Statistics are produced every number seconds.
* `chroot` (File Path, Default: undef): NSD will chroot on startup to the specified directory. (**untested**)
* `username` (String, Default: nsd): After binding the socket, drop user privileges and assume the username.
* `zonesdir` (File Path, Default: OS Specific): The data directory
* `difffile`: Ignored, for compatibility with NSD3 config files. Default: undef
* `xfrdfile`: The  soa  timeout  and zone transfer daemon in NSD will save its. Valid options: valid absolute path.  Default: OS Specific
* `xfrd_reload_timeout`: If this value is -1, xfrd will not trigger a reload after a zone transfer. If positive xfrd will trigger a reload after a zone transfer, then it will wait for the number of seconds before it will trigger a new reload. Setting this value throttles the reloads to once per the number of seconds. Valid options: Integer. Default: 1
* `verbosity`: This value specifies the verbosity level for (non-debug) logging. Default is 0. 1 gives more information about incoming notifies and zone transfers. 2 lists soft warnings that are encountered. 3 prints more information. Valid options: Integer < 3. Default: 0
* `hide_version`: Prevent NSD from replying with the version string on CHAOS class queries. Valid Optional: bool. Default: false
* `rrl_size`: This option gives the size of the  hashtable. Valid Optional Integer. Default: 1000000
* `rrl_ratelimit` (Integer, Default:200):  The max qps allowed.
* `rrl_slip` (Integer=2): This option controls the number of packets discarded before we send back a SLIP response
* `rrl_ipv4_prefix_length` (Integer < 33, Default: 24): IPv4 prefix length. Addresses are grouped by netblock.
* `rrl_ipv6_prefix_length` (Integer < 129, Default: 64): IPv6 prefix length. Addresses are grouped by netblock.
* `rrl_whitelist_ratelimit` (Integer, Default: 4000): The max qps for query sorts for a source, which have been whitelisted.
* `control_enable` (Bool, Default: false): Enable remote control
* `control_interface` (Array, Default: undef): the interfaces for remote control service 
* `control_port` (Integer < 65536, Default: 8952): the port number for remote control service 
* `server_key_file` (file path, Default: OS Specific): path to server private key
* `server_cert_file` (file path, Default: OS Specific): path to self signed certificate
* `client_key_file` (file path, Default: OS Specific): path to client private key
* `client_cert_file` (file path, Default: OS Specific): path to cient certificate
* `init` (String, Default: OS Specific): service provider to use
* `database` (File Path, Default: OS Specific): The specified file is u The specified file is
* `nsd_package_name` (String, Default: OS Specific): The package to install
* `nsd_service_name` (String, Default: OS Specific): The service to manage
* `zone_subdir` (File Path, Default: OS Specific): The zone directory
* `nsd_conf_file` (File Path, Default: OS Specific): The config file

### Private Classes

#### Class `nsd::params`

Set os specific parameters

### Private Defined Types

#### Defined `nsd::file`

Manage files used by nsd

##### Parameters 

* `owner` (String: Default root): the owner of the file
* `group` (String: Default nsd): the group of the file
* `mode` (String /^\d+$/: Default '0640'): the mode of the file
* `source` (File Path: Default undef): the source location of the file
* `content` (File Path: Default undef): the content location of the file
* `ensure` (File Path: Default 'present'): how to ensure the file

#### Defined `nsd::tsig`

Manage tsig keys used by nsd

##### Parameters 

* `algo` (String '^hmac-sha(1|224|256|384|512)$' or '^hmac-md5$', Default: 'hmac-sha256' ): The tsig algorithem of the key
* `data` (String, Required: true): The tsig key information
* `template` (Path, Default: 'nsd/etc/nsd/nsd.key.conf.erb'): template to use for tsig config

#### Defined `nsd::zone`

Manage a zone set conifg for nsd

##### Parameters 

* `masters` (Array, Default: []): List of master server to configure
* `notify_addresses` (Array, Default: []): List of serveres to notify
* `allow_notify` (Array, Default: []): List of servers allowed to notify
* `provide_xfr` (Array, Default: []): List of servers allowed to preform xfr
* `zones` (Array, Default: []): List of zones with this configueration
* `zonefile` (String, Default: undef): zonefile name, (will be used for all zones)
* `zone_dir` (File Path, Default: undef): override default zone path

### Facts

#### Fact `nsd_version`

Determins the version of nsd by parsing the output of `nsd -v`

## Limitations

This module has been tested on:

* Ubuntu 12.04, 14.04
* FreeBSD 10

## Development

Pull requests welcome but please also update documentation and tests.
test
