class drbd::params {
  case $::osfamily {
    'RedHat': {
      $version        = '8.4'
      $package_name   = 'drbd84-utils'
      $manage_repo    = true
    }
    default: {
      $version        = '8.4'
      $package_name   = 'drbd-utils'
      $manage_repo    = false
    }
  }
}
