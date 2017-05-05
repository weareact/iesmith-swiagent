# Author: Iain Smith <iain@iesmith.net>, 26/04/2017

# Compatability notes: Not compatible with Puppet 2.6.2 and earlier, due to
# style of inheritance from params class: 
# http://puppet-lint.com/checks/class_inherits_from_params_class/

class swiagent(
    $bindir = $swiagent::params::bindir,
    $targethost = $swiagent::params::targethost,
    $targetport = $swiagent::params::targetport,
    $targetuser = $swiagent::params::targetuser,
    $targetpw = $swiagent::params::targetpw,
    $agentpush = $swiagent::params::agentpush,
    $agentsecret = $swiagent::params::agentsecret,
    $proxyhost = $swiagent::params::proxyhost,
    $proxyport = $swiagent::params::proxyport,
    $proxyuser = $swiagent::params::proxyuser,
    $proxypw = $swiagent::params::proxypw,
    $manageswipkg = $swiagent::params::manageswipkg,
    $managepkgs = $swiagent::params::managepkgs,
    $nokogiripkg = $swiagent::params::nokogiripkg,
    $testpath = $swiagent::params::testpath,
    $catpath = $swiagent::params::catpath,
    $rmpath = $swiagent::params::rmpath
  ) inherits swiagent::params {

  # Validate supplied options...
  if !$agentpush and !$agentsecret {
    # A shared secret is mandatory if we're setting server-initiated 
    # communications...
    fail('agentpush parameter set to false, but no agentsecret set.')
  }

  # Ensure that Solarwinds agents and dependant packages are installed... 
  if $manageswipkg {
    package { 'swiagent': ensure => present }
  }
  if $managepkgs {
    package { $nokogiripkg: ensure => present }
  }

  # If no configuration file exists, create one and initialise the
  # securestring...
  exec { 'swiagent-init':
    onlyif  => "${testpath} ! -f ${bindir}/swiagent.cfg",
    command => "${bindir}/swiagent /logfile /initsecurestring",
  }

  # We don't want to leave Orion passwords lying around in the ini file, 
  # but at the same time, we want to be able to detect config changes.
  # The SHA1 achieves both these ends, but it does mean we'll have to 
  # create a temporary ini file to feed to swiagent with the real 
  # password when required.
  $targetpwhash = sha1($targetpw)
  $proxypwhash = sha1($proxypw)

  # Build the 'permanent' file for swiagent configuration...
  file { 'swi-settings-init':
    path    => "${bindir}/swi.ini",
    mode    => '0600',
    owner   => 'swiagent',
    group   => 'swiagent',
    content => template('swiagent/swi.ini.erb'),
    notify  => Exec['swi-settings-temp']
  }

  # Create a temporary file containing the real passwords, which will
  # be deleted by a subsquent exec. A temporary file will prevent the
  # exposure of plaintext passwords in the process table...
  exec { 'swi-settings-temp':
    cwd         => $bindir,
    umask       => '0177',
    onlyif      => "${testpath} -f swi.ini",
    command     => "/bin/sed -e 's/${targetpwhash}/${targetpw}/g' -e 's/${proxypwhash}/${proxypw}/g' < swi.ini > swi.ini.tmp",
    refreshonly => true,
    notify      => Exec['swi-register']
  }

  # Register the installed agent with Solarwinds, and delete the settings
  # file (it may have a password present)...
  exec { 'swi-register':
    cwd         => $bindir,
    onlyif      => "${testpath} -f swi.ini.tmp",
    # command     => "${bindir}/swiagent < swi.ini.tmp; ${rmpath} -f ${bindir}/swi.ini.tmp",
    command     => "${bindir}/swiagent < swi.ini.tmp",
    refreshonly => true
  }

  # Ensure the service is running...
  service {'swiagentd':
    ensure => running,
    enable => true
  }
}
