#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
#  [package_name] Defaults for CentOS / RHEL 7 compatibility
#    Set to drbd8-utils for Debian Wheezy or Jessie
#  [package_ensure] Defaults to installing, but not updating the package
#    Set to latest to allow the package to be updated

class drbd(
  $service_enable = true
  $package_name   = 'drbd84-utils'
  $package_ensure = present
) {
  include ::drbd::service

  package { 'drbd':
    ensure  => $package_ensure,
    name    => $package_name,
  }

  # ensure that the kernel module is loaded
  exec { 'modprobe drbd':
    path   => ['/bin/', '/sbin/'],
    unless => 'grep -qe \'^drbd \' /proc/modules',
  }

  File {
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['drbd'],
    notify  => Class['drbd::service'],
  }

  file { '/drbd':
    ensure => directory,
    mode   => '0755',
  }

  # this file just includes other files
  file { '/etc/drbd.conf':
    source  => 'puppet:///modules/drbd/drbd.conf',
  }

  file { '/etc/drbd.d/global_common.conf':
    content => template('drbd/global_common.conf.erb'),
  }

  # only allow files managed by puppet in this directory.
  file { '/etc/drbd.d':
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['drbd'],
  }

}
