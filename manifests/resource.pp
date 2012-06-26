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
  $host1,
  $host2,
  $ip1,
  $ip2,
  $disk,
  $secret        = false,
  $port          = '7789',
  $device        = '/dev/drbd0',
  $protocol      = 'C',
  $verify_alg    = 'crc32c',
  $manage        = true,
  $ha_primary    = false,
  $initial_setup = false,
  $fs_type       = 'ext4'
) {

  Exec {
    path => ['/bin', '/sbin', '/usr/bin']
  }

  File {
    owner => 'root',
    group => 'root',
  }

  file { "/drbd/${name}":
    ensure => directory,
    mode   => 0755,
  }

  file { "/etc/drbd.d/${name}.res":
    mode    => '0600',
    content => template('drbd/resource.res.erb'),
    require => Package['drbd'],
    notify  => Service['drbd'],
  }

  if $manage {

    # create metadata on device, except if resource seems already initalized.
    exec { "intialize DRBD metadata for ${name}":
      command => "drbdadm create-md ${name}",
      onlyif  => "test -e $disk",
      unless  => "drbdadm dump-md $name || (drbdadm cstate $name | egrep -q '^(Sync|Connected)')",
      before  => Service['drbd'],
      require => [
        Exec['modprobe drbd'],
        File["/etc/drbd.d/${name}.res"],
      ],
    }

    exec { "enable DRBD resource ${name}":
      command => "drbdadm up ${name}",
      onlyif  => "drbdadm dstate ${name} | egrep -q '^Diskless/|^Unconfigured'",
      before  => Service['drbd'],
      require => [
        Exec["intialize DRBD metadata for ${name}"],
        Exec['modprobe drbd']
      ],
      notify  => Service['drbd']
    }


    # these resources should only be applied if we are configuring the
    # primary node in our HA setup
    if $ha_primary {
  
      # these things should only be done on the primary during initial setup
      if $initial_setup {
        exec { "drbd_make_primary_${name}":
          command     => "drbdadm -- --overwrite-data-of-peer primary ${name}",
          path        => '/usr/bin:/usr/sbin:/bin:/sbin',
          notify      => Exec["drbd_format_volume_${name}"],
          onlyif      => "/bin/bash -c 'drbdadm status | grep ro1=.Secondary. | grep -q ro2=.Secondary.'",
          require     => Service['drbd']
        }
        exec { "drbd_format_volume_${name}":
          command     => "mkfs.${fs_type} ${device}",
          path        => '/usr/bin:/usr/sbin:/bin:/sbin',
          refreshonly => true,
          require     => Exec["drbd_make_primary_${name}"],
          before      => Mount["/drbd/${name}"]
        }
      }
  
      # ensure that the device is mounted
      mount { "/drbd/${name}":
        atboot  => false,
        device  => $device,
        ensure  => mounted,
        fstype  => 'auto',
        options => 'defaults,noauto',
        require => [
          File["/drbd/${name}"],
          Service['drbd']
        ],
      }
  
    }

  }
}
