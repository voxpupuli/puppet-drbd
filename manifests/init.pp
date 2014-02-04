#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd {
  include drbd::params
  include drbd::package
  include drbd::config
  include drbd::service

}
