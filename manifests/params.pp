class drbd::params {
  $ensure = 'present'

  case $::osfamily {
    'RedHat' : { $drbd_package = 'drbd84-utils'
      $drbd_kernel_package = 'kmod-drbd84-8.4.5-1.el6.elrepo'
    }
    'Debian' : { $drbd_package = ['drbd8-utils'] }
    default  : { fail("\"${module_name}\" is not supported on \"${::operatingsystem}\"") }
  }

}