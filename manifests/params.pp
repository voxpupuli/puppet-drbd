class drbd::params {
  case $::osfamily {
    'RedHat': {
      $version           = '8.4'
      $package_name      = 'drbd84-utils'
      $kmod_package_name = 'kmod-drbd84'
      $manage_repo       = true
    }
    default: {
      $version           = '8.4'
      $package_name      = 'drbd-utils'
      $kmod_package_name = undef
      $manage_repo       = false
    }
  }
}
