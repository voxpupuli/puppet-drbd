require 'spec_helper'

describe 'drbd', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should contain_class('drbd::service') }
      case facts[:osfamily]
      when 'RedHat'
        it { should contain_package('drbd84-utils') }
      else
        it { should contain_package('drbd-utils') }
      end
      it { should contain_exec('modprobe drbd') }
      it { should contain_file('/drbd') }
      it { should contain_file('/etc/drbd.conf') }
      it { should contain_file('/etc/drbd.d').with_ensure('directory').with_purge(true) }
      describe '/etc/drbd.d/global_common.conf' do
        context 'when drbd 8.4' do
          it 'has correct global section' do
            content = catalogue.resource('file', '/etc/drbd.d/global_common.conf').send(:parameters)[:content]
            expect(content).to include('usage-count no;')
            global_section  = %(global {\n)
            global_section += %(  usage-count no;\n)
            global_section += %(}\n)
            expect(content).to include(global_section)
          end
          it 'has correct common section' do
            content = catalogue.resource('file', '/etc/drbd.d/global_common.conf').send(:parameters)[:content]
            common_section  = %(common {\n)
            common_section += %(  net {\n)
            common_section += %(    protocol C;\n)
            common_section += %(  }\n)
            common_section += %(}\n)
            expect(content).to include(common_section)
          end
        end
        context 'when drbd 8.3' do
          let(:params) { { version: '8.3' } }
          it 'has correct common section' do
            content = catalogue.resource('file', '/etc/drbd.d/global_common.conf').send(:parameters)[:content]
            common_section  = %(common {\n)
            common_section += %(  protocol C;\n)
            common_section += %(}\n)
            expect(content).to include(common_section)
          end
        end
        context 'when protocol is set to B' do
          let(:params) { { protocol: 'B' } }
          it do
            is_expected.to contain_file('/etc/drbd.d/global_common.conf').with_content %r{protocol B;$}
          end
        end
      end
    end
  end
end
