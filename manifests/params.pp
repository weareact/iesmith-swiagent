# Author: Iain Smith <iain@iesmith.net>, 26/04/2017

class swiagent::params {
  # Generic default settings...
  $bindir = hiera('swiagent::bindir', '/opt/SolarWinds/Agent/bin')
  $targethost = hiera('swiagent::targethost', 'solarwinds.example.com')
  $targetport = hiera('swiagent::targetport', 17778)
  $targetuser = hiera('swiagent::targetuser', 'admin')
  $targetpw = hiera('swiagent::targetpw', undef)
  $proxyhost = hiera('swiagent::proxyhost', false)
  $proxyport = hiera('swiagent::proxyport', 3128)
  $proxyuser = hiera('swiagent::proxyuser', undef)
  $proxypw = hiera('swiagent::proxypw', undef)
  $manageswipkg = hiera('swiagent::manageswipkg', false)

  # Use temporary variables here, since they may be overridden later...
  $_managepkgs = hiera('swiagent::managepkgs', true)

  case $::os['family'] {
    'RedHat': {
      # Assign package names...
      $nokogiripkg = 'rubygem-nokogiri'
      $managepkgs = $_managepkgs

      # Assign basic binary paths...
      $testpath = '/usr/bin/test'
      $catpath = '/usr/bin/cat'
    }
    default: {
      # TODO: We'll need to draw attention to default handing here later on...
      $managepkgs = false
    }
  }
}
