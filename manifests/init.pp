#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd {
  include drbd::service

  package { 'drbd':
    ensure => present,
    name   => 'drbd8-utils',
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
    content => template('drbd/global_common.conf.erb')
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

#  exec { "fix_drbd_runlevel":
#    command     =>  "update-rc.d -f drbd remove && update-rc.d drbd defaults 19",
#    path        => [ "/sbin", "/usr/sbin", "/usr/bin/" ],
#    unless      => "stat /etc/rc3.d/S19drbd",
#    require => Package['drbd8-utils']
#  }
}
