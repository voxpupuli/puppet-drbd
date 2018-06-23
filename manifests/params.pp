class drbd::params {

  $default_package_name = 'drbd8-utils'

  case $::osfamily {
    'Debian': {
      $package_name = $default_package_name
    }
    'RedHat': {
      $package_name = [ 'drbd84-utils', 'kmod-drbd84' ]
    }
  }
}