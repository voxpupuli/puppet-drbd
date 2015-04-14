class drbd::params {
  $ensure = 'present'

  case $::osfamily {
    'RedHat' : {
      $drbd_package = 'drbd84-utils'
      $drbd_kernel_package = 'kmod-drbd84-8.4.5-1.el6.elrepo'
    }
    'Debian' : {
      $drbd_package = ['drbd8-utils']
    }
    default  : {
      fail("drbd is not supported on \"${::osfamily}\"")
    }
  }

}