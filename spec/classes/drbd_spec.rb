require 'spec_helper'

describe 'drbd', type: :class do
  shared_examples 'drbd shared example' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('drbd::service') }
    it { is_expected.to contain_exec('modprobe drbd') }
    it { is_expected.to contain_file('/drbd') }
    it { is_expected.to contain_file('/etc/drbd.conf') }
    it { is_expected.to contain_file('/etc/drbd.d').with_ensure('directory').with_purge(true) }

    it do
      is_expected.to contain_file('/etc/drbd.d/global_common.conf').with_content %r{usage-count no;$}
      is_expected.to contain_file('/etc/drbd.d/global_common.conf').with_content %r{protocol C;$}
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it_behaves_like 'drbd shared example'

      it do
        if facts[:os]['family'] == 'Debian'
          is_expected.to contain_package('drbd').with_name('drbd-utils')
        else
          is_expected.to contain_package('drbd').with_name('drbd8-utils')
        end
      end
    end
  end
end
