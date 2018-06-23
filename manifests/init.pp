#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd(
  $service_enable = true,
# Package name from the params file
  $package_name = $drbd::params::package_name,
# Inherit the main class from params class

) inherits drbd::params {
  include ::drbd::service

#Update package name

  package { $package_name:
    ensure => present,
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
    require => Package[$package_name],
    notify  => Class['drbd::service'],
  }

  file { '/drbd':
    ensure => directory,
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
    mode    => '0644',
    purge   => false,   #Setting true won't allow to create more than one drbd volumes. 
    recurse => true,
    force   => true,
    require => Package[$package_name],
  }

}
