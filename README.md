# swiagent

#### Table of Contents

1. [Overview](#overview)
2. [Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)

## Overview

The swiagent module can be used to control and deploy the Solarwinds Linux agent in ways not possible via the Solarwinds Orion interface.

## Module Description

While agents can be deployed from the Solarwinds console itself, there are many use case in which this isn't simply possible. One, which led to the development of this module, is the possiblity that the monitored hosts reside within a secure network, such as a DMZ in which *only* limited inbound and outbound connections are possible.

## Setup

```bash
puppet module install iesmith-swiagent
```

## Usage

Swiagent was written with the intent of configuring the module via Hiera, though it may be equally well configured via a class declaration. 

## Reference

#### `targethost`

Data type: String.

Hostname or IP address of your Orion server.

Default value: `solarwinds.example.com`

#### `targetport`

Data type: Integer.

Orion SDK port.

Default value: `17778`

#### `targetuser`

Data type: String.

Username of an Orion user with sufficient privileges to create nodes within NPM on the server specified in `targethost`.

Default value: `admin`

#### `targetpw`

Valid password for the user specified in `targetuser`.

Data type: String.

Default value: `undef`

#### `proxyhost`

Data type: String.

Hostname or IP address of an HTTPS-capable proxy server. On a [Squid](http://www.squid-cache.org/) proxy, HTTPS clients must have CONNECT privileges to the Orion SDK port. This is not permitted in the default configuration, though the following modification should allow this.

On RedHat-based systems Squid comes preconfigured with an SSL_ports ACL. Simply adding 17778 to this ACL should permit the agent to communicate:

```shell
acl SSL_ports port 443 8140 *17778*
acl CONNECT method CONNECT
http_access deny CONNECT !SSL_ports
```

Obviously additional ACLs will be required to permit access; this ACL is simply meant to *prevent* a CONNECT to non-SSL ports.

Default value: `undef`

#### `proxyport`

Data type: Integer.

Proxy server port; commonly TCP/8080 or TCP/3128.

Default value: `3128`

#### `proxyuser`

Data type: String.

Username of an proxy user with sufficient privileges to CONNECT (see: `proxyhost`) to the server specified in `targethost`.

Default value: `undef`

#### `proxypw`

Data type: String.

Valid password for the user specified in `proxyuser`.

Default value: `undef`

#### `managepkgs`

Data type: Boolean.

Installs dependency packages. At present this only includes the [Nokogiri package](http://www.nokogiri.org/), a Rubygem used for parsing the XML swiagent.cfg file.

Default value: `true`

#### `manageswipkg`

Data type: Boolean.

Installs the swiagent package via whichever repositories you may have set up. Note that while it's possible to set up various package management systems to pull the agents directly from Orion, this does involve additional setup work, and as such is a non-default option.

The following example sets up a Yum repository on CentOS 7 to pull the RPM package straight from your Orion server:

```shell
[orion]
name=Orion Package Repo
baseurl=https://orion.example.com/Orion/AgentManagement/LinuxPackageRepository.ashx?path=/dists/centos-7/$basearch/
enabled=1
gpgcheck=0
```

Default value: `false`

#### `bindir`

Data type: String.

The path into which the Solarwinds agents will be installed. As far as I'm aware, all of the various Linux agent packages install binaries into this directory, so changing this requires fairly careful thought.

Default value: `/opt/SolarWinds/Agent/bin`

## Limitations

At present the module has only been tested under RedHat/CentOS versions 6 & 7. 

