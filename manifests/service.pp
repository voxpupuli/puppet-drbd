class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => $drbd::service_enable,
    require => Package[$::package_name],
    restart => 'service drbd reload',
  }
}
