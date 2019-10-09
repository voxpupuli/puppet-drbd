require 'spec_helper'

describe 'drbd::resource', type: :define do
  let(:title) { 'mock_drbd_resource' }
  let(:default_facts) do
    { concat_basedir: '/dne' }
  end
  let(:default_params) do
    {
      disk: '/dev/mock_disk',
      initial_setup: true,
      host1: 'mock_primary',
      host2: 'mock_secondary',
      ip1: '10.16.0.1',
      ip2: '10.16.0.2',
      ha_primary: false
    }
  end

  shared_examples 'drbd::resource generic example' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('drbd') }
      it {
        is_expected.to contain_file('/drbd/' + title).
          with_ensure('directory').
          with_mode('0755').
          with_owner('root').
          with_group('root')
      }
      it {
        is_expected.to contain_concat('/etc/drbd.d/' + title + '.res').
          with_mode('0600')
      }
      it {
        is_expected.to contain_concat__fragment(title + ' drbd header').
          with_target('/etc/drbd.d/' + title + '.res').
          with_order('01')
      }
      it {
        is_expected.to contain_concat__fragment(title + ' drbd footer').
          with_target('/etc/drbd.d/' + title + '.res').
          with_content("}\n").
          with_order('99')
      }
      it {
        is_expected.to contain_drbd__resource__enable(title)
      }
    end
  end

  context 'DRBD metadisk' do
    describe 'defaults to internal' do
      let(:params) do
        default_params
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*meta-disk internal;$})
      }
    end
    describe 'set external flexible metadisk' do
      let(:params) do
        {
          flexible_metadisk: '/dev/vg00/drbd-meta[0]'
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*flexible-meta-disk \/dev\/vg00\/drbd-meta\[0\];$})
      }
    end
  end

  context 'initialization of DRBD metadata' do
    describe 'with initialize::false' do
      let :params do
        {
          initialize: false
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it { is_expected.not_to contain_exec('initialize DRBD metadata for mock_drbd_resource') }
    end
    describe 'with initialize::true' do
      let :params do
        {
          initialize: true
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it { is_expected.to contain_exec('initialize DRBD metadata for mock_drbd_resource') }
    end
  end

  context 'handlers_parameters' do
    describe 'with no handlers' do
      let(:params) do
        default_params
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*handlers \{$})
      }
    end
    describe 'with a set value' do
      let :params do
        {
          'handlers_parameters' =>
            {
              'split-brain' => '"/usr/lib/drbd/notify-split-brain.sh"'
            }
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*handlers \{\n\s*split-brain "\/usr\/lib\/drbd\/notify-split-brain.sh";$})
      }
    end
  end

  context 'startup_parameters' do
    describe 'with no startup' do
      let(:params) do
        default_params
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*startup \{$})
      }
    end
    describe 'with a set value' do
      let :params do
        {
          'startup_parameters' =>
            {
              'wfc-timeout' => 0
            }
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*startup \{\n\s*wfc-timeout 0;$})
      }
    end
  end
  context 'syncer config: verify_alg and rate' do
    describe 'with default values' do
      let(:params) do
        default_params
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*syncer \{\n\s*verify-alg crc32c;$})
      }
      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*rate.*;$})
      }
    end
    describe 'with rate of 1M' do
      let :params do
        {
          rate: '1M'
        }.merge(default_params)
      end

      it_behaves_like 'drbd::resource generic example'

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*syncer \{\n.*\s*rate 1M;$})
      }
    end
  end
end
# it { pp catalogue.resources }
