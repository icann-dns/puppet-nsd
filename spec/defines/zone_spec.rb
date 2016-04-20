require 'spec_helper'

describe 'nsd::zone', :type => :define do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:pre_condition) { ['include ::nsd'] }
      let(:title) { 'example.com' }
      describe 'basic check' do
        let(:params) {{
          'masters'          => ['192.0.2.1'],
          'notify_addresses' => ['192.0.2.1'],
          'allow_notify'     => ['192.0.2.1'],
          'provide_xfr'      => ['192.0.2.1'],
          'zones'            => ['example.com'],
          'rrl_whitelist'    => ['nxdomain'],
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat_fragment('nsd_zones_example.com').with_content(
            /name: "example.com"/
          ).with_content(
            /zonefile:.+example.com/
          ).with_content(
            /notify: 192.0.2.1 NOKEY/
          ).with_content(
            /allow-notify: 192.0.2.1 NOKEY/
          ).with_content(
            /request-xfr: AXFR 192.0.2.1/
          ).with_content(
            /provide-xfr: 192.0.2.1 NOKEY/
          ).with_content(
            /rrl-whitelist: nxdomain/
          )
        }
      end

      describe 'Check bad params' do
        context 'masters' do
          let(:params) {{ :masters => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'notify_addresses' do
          let(:params) {{ :notify_addresses => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'allow_notify' do
          let(:params) {{ :allow_notify => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'provide_xfr' do
          let(:params) {{ :provide_xfr => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zones' do
          let(:params) {{ :zones => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zonefile' do
          let(:params) {{ :zonefile => true }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zone_dir' do
          let(:params) {{ :zone_dir => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rrl_whitelist' do
          let(:params) {{ :rrl_whitelist => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end

    end
  end
end
