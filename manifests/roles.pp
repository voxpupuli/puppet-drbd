# Class definitions for each Instance Role output by the ENC script
class baserole {
  class { 'oracle_java': type => 'jdk', }

  rhn_register { 'spacewalk.ordsvy.gov.uk':
    activationkeys => '4-vagrant-csp-oel6-x86_64',
    server_url     => 'http://spacewalk.ordsvy.gov.uk/XMLRPC',
  }

  @@host { $::fqdn:
    ip           => $::ipaddress,
    host_aliases => $::hostname,
  }
}

class puppetmaster inherits baserole {
  tidy { "puppet::reports":
    path    => '/var/lib/puppet/reports',
    matches => '*',
    age     => '14d',
    backup  => false,
    recurse => true,
    rmdirs  => false,
    type    => 'ctime',
  }
}

class applicationserver inherits baserole {
}

class dbsetup inherits baserole {
  rpmkey { '0608B895':
    ensure => present,
    source => 'http://spacewalk.ordsvy.gov.uk/pub/RPM-GPG-KEY-EPEL-6',
  }

  rpmkey { '442DF0F8':
    ensure => present,
    source => 'http://spacewalk.ordsvy.gov.uk/pub/RPM-GPG-KEY-PGDG-90',
  }

  rpmkey { 'BAADAE52':
    ensure => present,
    source => 'http://spacewalk.ordsvy.gov.uk/pub/RPM-GPG-KEY-elrepo',
  }

  file { '/u01': ensure => directory }

  file { '/u01/csp':
    ensure  => directory,
    require => Class['lvm'],
  }

  physical_volume { '/dev/sdb': ensure => present, }

  volume_group { 'vg_drbd01':
    ensure           => present,
    physical_volumes => '/dev/sdb',
  }

  logical_volume { 'lv_drbd_u01':
    ensure       => present,
    volume_group => 'vg_drbd01',
    size         => '10G',
  }

}

class drbdsetup inherits dbsetup {
  include drbd

  drbd::resource { 'pgdgdata':
    host1 => 'db1.strivedi.ordsvy.gov.uk',
    host2 => 'db2.strivedi.ordsvy.gov.uk',
    ip1   => '10.1.172.31',
    ip2   => '10.1.172.32',
    disk  => '/dev/vg_drbd01/lv_drbd_u01',
  }
}

class databaseserver inherits drbdsetup {
  class { 'postgresql::globals':
    manage_package_repo => false,
    version             => '9.4',
    datadir             => '/u01/csp/pgsql',
    require             => [Rpmkey['0608B895', '442DF0F8'], File['/u01/csp']]
  } ->
  class { 'postgresql::server':
    listen_addresses => '*',
    encoding         => 'UTF-8',
    needs_initdb     => true,
  }

  $applicationNetwork = ["10.172.1.0/24"]
  $cspdb_schema = ["ENTITLEMENTSTORE", "AUTHORIZATION"]
  postgresql::server::pg_hba_rule { "allow $applicationNetwork to access app database":
    description => "Open up postgresql for access from $applicationNetwork",
    type        => 'host',
    database    => 'all',
    user        => 'all',
    address     => $applicationNetwork,
    auth_method => 'md5',
  } ->
  postgresql::server::db { 'csp':
    user     => 'csp_admin',
    password => postgresql_password('csp_admin', 'SKrYk897jtdC48u'),
  } ->
  postgresql::server::role { "csp_user": password_hash => postgresql_password('csp_user', '2qYewg2P7H3RU5p'), } ->
  postgresql::server::database_grant { 'csp':
    privilege => 'CONNECT',
    db        => 'csp',
    role      => 'csp_user',
  } ->
  postgresql::server::schema { $cspdb_schema:
    owner => 'csp_admin',
    db    => 'csp',
  }

  ::postgresql::server::grant { 'grant csp_user on entitlementstore schema':
    object_name => 'ENTITLEMENTSTORE',
    object_type => 'ALL TABLES IN SCHEMA',
    role        => 'csp_user',
    db          => 'csp',
    privilege   => 'SELECT INSERT UPDATE DELETE',
    require     => [Postgresql::Server::Db['csp'], Postgresql::Server::Schema['ENTITLEMENTSTORE']],
  }

  class { 'postgresql::server::postgis':
  }

}

class databasemaster {
  include databaseserver
}

class databaseslave inherits dbsetup {

}