#Class to add the package name 
#
class drbd::params {
    case $::facts['os']['family'] {
        'Debian': {
            $package_name = 'drbd8-utils'
        }
        'RedHat': {
            $package_name = [ 'drbd84-utils', 'kmod-drbd84' ]
        }
        default: {
          $package_name = 'drbd8-utils'
        }
    }
}
