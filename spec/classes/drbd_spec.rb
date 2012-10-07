require 'spec_helper'

describe 'drbd', :type => :class do
  it { should include_class('drbd::service') }
  it { should contain_package('drbd') }
  it { should contain_exec('modprobe drbd') }
  it { should contain_file('/drbd') }
  it { should contain_file('/etc/drbd.conf') }
  it { should contain_file('/etc/drbd.d').with_ensure('directory').with_purge(true) }
  it {
    should contain_file('/etc/drbd.d/global_common.conf')
    verify_contents(subject, '/etc/drbd.d/global_common.conf', [
      '  usage-count no;',
      '  protocol C;',
    ])
  }
end
