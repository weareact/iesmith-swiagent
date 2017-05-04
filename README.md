# swiagent

#### Table of Contents

1. [Overview](#overview)
2. [Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)

## Overview

The swiagent module can be used to control and deploy the Solarwinds Linux
agent in ways not possible via the Solarwinds Orion interface.

## Module Description

While agents can be deployed from the Solarwinds console itself, there
are many use case in which this isn't simply possible. One, which led to the 
development of this module, is the possiblity that the monitored hosts reside
within a secure network, such as a DMZ in which *only* limited inbound and 
outbound connections are possible.

## Setup

~~~bash
puppet module install iesmith-swiagent
~~~

## Usage

Swiagent was written with the intent of configuring the module via Hiera, 
though it may be equally well configured via a class declaration. 

## Reference

#### `bindir`

Data type: String.

The path into which the Solarwinds agents will be installed. As far as I'm
aware, all of the various Linux agent packages install binaries into this 
directory, so changing this requires some careful thought.

Default value: `/opt/SolarWinds/Agent/bin`

#### `targethost`

Data type: String.

Default value: `solarwinds.example.com`

#### `targetport`

Data type: Integer.

Default value: `17778`

#### `targetuser`

Data type: String.

Default value: `admin`

#### `targetpw`

Data type: String.

Default value: `undef`

#### `proxyhost`

Data type: String.

Default value: `undef`

#### `proxyport`

Data type: String.

Default value: `3128`

#### `proxyuser`

Data type: String.

Default value: `undef`

#### `proxypw`

Data type: String.

Default value: `undef`

#### `manageswipkg`

Data type: String.

Installs the swiagent package via whichever repositories you may have set up.
Note that while it's possible to set up various package management systems
to pull the agents directly from Orion, this does involve additional setup work,
and as such is a non-default option.

The following example sets up a Yum repository on CentOS 7 to pull the RPM 
package straight from your Orion server:

```shell
[orion]
name=Orion Package Repo
baseurl=https://orion.example.com/Orion/AgentManagement/LinuxPackageRepository.ashx?path=/dists/centos-7/$basearch/
enabled=1
gpgcheck=0
```

Default value: `false`

## Limitations

At present the module has only been tested under RedHat/CentOS versions 6 & 7. 

