$primary_host   = 'HOST1'
$secondary_host = 'HOST2'
$primary_ip     = '10.0.0.3'
$secondary_ip   = '10.0.0.4'
$physical_disk  = '/dev/sdb1'
$drbd_name      = 'drbd0'
$drbd_port      = '7789'
$drbd_device    = '/dev/drbd0'

node 'HOST1' {

  host {

    $primary_host:
        ip     => $primary_ip,
        ensure => present,

        }

  host {

    $secondary_host:
        ip      =>  $secondary_ip,
        ensure  =>  present,

        }

  include ::drbd

  drbd::resource { $drbd_name:
    host1          => $primary_host,
    host2          => $secondary_host,
    ip1            => $primary_ip,
    ip2            => $secondary_ip,
    disk           => $physical_disk,
    port           => $drbd_port,
    device         => $drbd_device,
    secret         => 'password',
    net_parameters => {'after-sb-0pri' => 'discard-zero-changes', 'after-sb-1pri' => 'discard-secondary', 'after-sb-2pri' => 'disconnect', 'max-buffers' => '8000', 'max-epoch-size' => '8000', 'sndbuf-size' => '0'},
    rate           => '500M',
    manage         => true,
    verify_alg     => 'sha1',
    ha_primary     => true,
    initial_setup  => true,
    automount      => false,
  }
}

node 'HOST2' {

   host {

    $primary_host:
        ip     => $primary_ip,
        ensure => present,

        }

  host {

    $secondary_host:
        ip      =>  $secondary_ip,
        ensure  =>  present,

        }

  include ::drbd

  drbd::resource { $drbd_name:
    host1          => $primary_host,
    host2          => $secondary_host,
    ip1            => $primary_ip,
    ip2            => $secondary_ip,
    disk           => $physical_disk,
    port           => $drbd_port,
    device         => $drbd_device,
    rate           => '500M',
    secret         => 'password',
    net_parameters => {'after-sb-0pri' => 'discard-zero-changes', 'after-sb-1pri' => 'discard-secondary', 'after-sb-2pri' => 'disconnect', 'max-buffers' => '8000', 'max-epoch-size' => '8000', 'sndbuf-size' => '0'},
    manage         => true,
    verify_alg     => 'sha1',
    ha_primary     => false,
    initial_setup  => false,
    automount      => false,
  }
}