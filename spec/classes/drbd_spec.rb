require 'spec_helper'

describe 'drbd', type: :class do
  it { should contain_class('drbd::service') }
  it { should contain_package('drbd') }
  it { should contain_exec('modprobe drbd') }
  it { should contain_file('/drbd') }
  it { should contain_file('/etc/drbd.conf') }
  it { should contain_file('/etc/drbd.d').with_ensure('directory').with_purge(true) }
  it do
    should contain_file('/etc/drbd.d/global_common.conf').with_content %r{usage-count no;$}
    should contain_file('/etc/drbd.d/global_common.conf').with_content %r{protocol C;$}
  end
end
