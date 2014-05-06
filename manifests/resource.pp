# Used to created a resource that replicates data
# between 2 hosts for HA.
#
# == Parameters
#  [host1] Name of first host. Required.
#  [host2] Name of second host. Required.
#  [ip1] Ipaddress of first host. Required.
#  [ip2] Ipaddress of second host. Required.
#  [disk] Name of disk to be replicated. Assumes that the
#     name of the disk will be the same on both hosts. Required.
#  [secret] The shared secret used in peer authentication.. False indicates that
#    no secret be required. Optional. Defaults to false.
#  [port] Port which drbd will use for replication on both hosts.
#     Optional. Defaults to 7789.
#  [protocol] Protocal to use for drbd. Optional. Defaults to '3'
#     http://www.drbd.org/users-guide/s-replication-protocols.html
#  [verify_alg] Algorithm used for block validation on peers. Optional.
#    Defaults to crc32c. Accepts crc32c, sha1, or md5.
#  [manage] If the actual drbd resource shoudl be managed.
#  [ha_primary] If the resource is being applied on the primary host.
#  [initial_setup] If this run is associated with the initial setup. Allows a user
#    to only perform dangerous setup on the initial run.
define drbd::resource (
  $host1         = undef,
  $host2         = undef,
  $ip1           = undef,
  $ip2           = undef,
  $cluster       = undef,
  $disk,
  $secret        = false,
  $port          = '7789',
  $device        = '/dev/drbd0',
  $mountpoint    = "/drbd/${name}",
  $automount     = true,
  $owner         = 'root',
  $group         = 'root',
  $protocol      = 'C',
  $verify_alg    = 'crc32c',
  $manage        = true,
  $ha_primary    = false,
  $initial_setup = false,
  $fs_type       = 'ext4'
) {
  include drbd

  Exec {
    path      => ['/bin', '/sbin', '/usr/bin'],
    logoutput => 'on_failure',
  }

  File {
    owner => 'root',
    group => 'root',
  }

  file { $mountpoint:
    ensure => directory,
    mode   => '0755',
    owner  => $owner,
    group  => $group,
  }

  concat { "/etc/drbd.d/${name}.res":
    mode    => '0600',
    require => [
      Package['drbd'],
      File['/etc/drbd.d'],
    ],
    notify  => Class['drbd::service'],
  }
  # Template uses:
  # - $name
  # - $protocol
  # - $device
  # - $disk
  # - $secret
  # - $verify_alg
  # - $host1
  # - $host2
  # - $ip1
  # - $ip2
  # - $port
  concat::fragment { "${name} drbd header":
    target  => "/etc/drbd.d/${name}.res",
    content => template('drbd/header.res.erb'),
    order   => '01',
  }
  # Export our fragment for the clustered node
  if $ha_primary and $cluster {
    @@concat::fragment { "${name} ${cluster} primary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/resource.res.erb'),
      order   => '10',
    }
  } elsif $cluster {
    @@concat::fragment { "${name} ${cluster} secondary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/resource.res.erb'),
      order   => '20',
    }
  } elsif $host1 and $ip1 and $host2 and $ip2 {
    concat::fragment { "${name} static primary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/primary-resource.res.erb'),
      order   => '10',
    }
    concat::fragment { "${name} static secondary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/secondary-resource.res.erb'),
      order   => '20',
    }
  } else {
    fail('Must provide either cluster or host1/host2/ip1/ip2 parameters')
  }

  concat::fragment { "${name} drbd footer":
    target  => "/etc/drbd.d/${name}.res",
    content => "}\n",
    order   => '99',
  }

  if $cluster {
    # Import cluster nodes
    Concat::Fragment <<| title == "${name} ${cluster} primary resource" |>>
    Concat::Fragment <<| title == "${name} ${cluster} secondary resource" |>>
  }

  # Due to a bug in puppet, defined() conditionals must be in a defined
  # resource to be evaluated *after* the collector instead of before.
  drbd::resource::enable { $name:
    manage        => $manage,
    disk          => $disk,
    fs_type       => $fs_type,
    device        => $device,
    ha_primary    => $ha_primary,
    initial_setup => $initial_setup,
    cluster       => $cluster ? {
      undef   => 'static',
      default => $cluster,
    },
    mountpoint    => $mountpoint,
    automount     => $automount,
  }
}
