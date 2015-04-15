# # This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd (
  $service_enable      = true,
  $drbd_package        = $drbd::params::drbd_package,
  $drbd_kernel_package = $drbd::params::drbd_kernel_package) inherits drbd::params {
  include drbd::service

  package { 'drbd':
    ensure => present,
    name   => $drbd_package,
  }

  if $drbd_kernel_package {
    package { 'drbd_kernel':
      ensure => present,
      name   => $drbd_kernel_package,
    }
  }

  # ensure that the kernel module is loaded
  exec { 'modprobe drbd':
    path   => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'grep -qe \'^drbd \' /proc/modules',
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['drbd'],
    notify  => Class['drbd::service'],
  }

  file { '/drbd': ensure => directory, }

  # this file just includes other files
  file { '/etc/drbd.conf': source => 'puppet:///modules/drbd/drbd.conf', }

  file { '/etc/drbd.d/global_common.conf': content => template('drbd/global_common.conf.erb') }

  # only allow files managed by puppet in this directory.
  file { '/etc/drbd.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    purge   => true,
    recurse => true,
    require => Package['drbd'],
    force   => true,
  }

}
