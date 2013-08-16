#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd::package {

  package { 'drbd':
    ensure => present,
    name   => $drbd::params::drbdpackage,
  }

  package { 'drbd-module':
    ensure => present,
    name   => $drbd::params::drbdkmod,
  }
}
