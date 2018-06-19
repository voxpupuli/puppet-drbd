#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd(
  $service_enable = true,
#The pacakage drbd8-utils does not work on CentOS 
  $package_name = 'drbd84-utils',
) {
  include ::drbd::service

  package { 'drbd':
    ensure => present,
    name   => $package_name,
  }
  
  #Kernel module should be installalled before loading it in CentOS 
  
   package { 'drbdModule':
    ensure => present,
    name   => 'kmod-drbd84'
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
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['drbd'],
  }

}
