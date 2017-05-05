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

```shell
puppet module install iesmith-swiagent
```

## Usage

Below is a relatively simple installation of an (already installed) swiagent, followed by configuration of the agent to talk to the Orion server 192.168.0.1, via a proxy at 192.168.0.2:8080.

```yaml
swiagent::targethost:   '192.168.0.1',
swiagent::targetuser:   'orionuser',
swiagent::targetpw:     'SuperSecretPassword',
swiagent::proxyhost:    '192.168.0.2',
swiagent::proxyport:    '8080'
```

Although iesmith-swgagent was written with the intent of configuring the module via Hiera, it may be equally well configured via a class declaration. Below is the same configuration written directly into a manifest. 

```puppet
class { '::swiagent':
    targethost   => '192.168.0.1',
    targetuser   => 'orionuser',
    targetpw     => 'SuperSecretPassword',
    proxyhost    => '192.168.0.2',
    proxyport    => '8080'
}
```

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

*Note*: The password will be SHA1 hashed for permanent storage in the swi.ini file, though it will be briefly exist in plaintext form in a (mode 600, root-owned) temporary file whilst Puppet is piping the information to swagent. This is an unfortunate (security-wise) neccessity as swagent must be given the plaintext password.

Data type: String.

Default value: `undef`

#### `agentpush`

Used to control the [agent communication mode](http://www.solarwinds.com/documentation/en/flarehelp/orionplatform/content/core-agent-communication-modes.htm?cshid=OrionAgentManagementPHActivePassiveAgent) of swiagentd. When set to true, the agent will operate in agent-initiated communication mode. On setting this parameter to `false`, `agentsecret` becomes *mandatory*.

*Note*: Server-initiated communication mode will require manual intervention in Solarwinds, and as such probably negates many of the advantages of using this module. In this situation, I'd be strongly inclined to push the agent install from the Orion console, though there may be use-cases I've not thought of. 

Data type: Boolean.

Default value: `true`

#### `agentsecret`

Sets a shared secret for use in server-initiated communication mode. This parameter is *mandatory* when `agentpush` is set to `false`. 

*Note*: Unlike `targetpw` and `proxypw`, the shared secret will not be hashed for storage in swi.ini.

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

Default value: `false`

#### `proxyport`

Data type: Integer.

Proxy server port; commonly TCP/8080 or TCP/3128.

Specified values will be ignored if `proxyhost` is not defined.

Default value: `3128`

#### `proxyuser`

Data type: String.

Username of an proxy user with sufficient privileges to CONNECT (see: `proxyhost`) to the server specified in `targethost`.

Specified values will be ignored if `proxyhost` is not defined.

Default value: `false`

#### `proxypw`

Data type: String.

Valid password for the user specified in `proxyuser`. Values will be ignored if `proxyhost` is not defined.

*Note*: The password will be SHA1 hashed for permanent storage in the swi.ini file, though it will be briefly exist in plaintext form in a (mode 600, root-owned) temporary file whilst Puppet is piping the information to swagent. This is an unfortunate (security-wise) neccessity as swagent must be given the plaintext password.

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

Server-initiated communication mode does not set up an agent or node in Orion. These will need to be created manually, and as such, probably negates the advantages of using this module.
