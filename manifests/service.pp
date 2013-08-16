class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => true,
    require => Package['drbd'],
    restart => 'service drbd reload',
  }
}
