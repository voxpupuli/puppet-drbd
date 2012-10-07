class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => true,
    require => Package['drbd8-utils'],
    restart => 'service drbd reload',
  }
}
