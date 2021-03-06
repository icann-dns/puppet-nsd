# frozen_string_literal: true

require 'spec_helper'

describe 'nsd::zone', type: :define do
  let(:pre_condition) do
    'class {\'::nsd\':
      tsigs   => {
        \'foobar\' => {
          data => \'asdasd\'
        }
      },
      remotes => {
        \'extra_allow_notify\' => {
          \'address4\' => \'192.0.2.4\',
          \'address6\' => \'2001:DB8::4\'
        },
        \'extra_notify\' => {
          \'address4\' => \'192.0.2.3\',
          \'address6\' => \'2001:DB8::3\'
        },
        \'master\' => {
          \'address4\' => \'192.0.2.1\',
          \'address6\' => \'2001:DB8::1\'
        },
        \'slave\' => {
          \'address4\' => \'192.0.2.2\',
          \'address6\' => \'2001:DB8::2\'
        }
      }
    }'
  end
  let(:title) { 'example.com' }
  let(:params) do
    {
      'masters'       => ['master'],
      'provide_xfrs'  => ['slave'],
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'basic check' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_concat_fragment(
            'nsd_zones_example.com',
          ).with_content(
            %r{name: "example.com"},
          ).with_content(
            %r{zonefile:.+example.com},
          ).with_content(
            %r{include-pattern: master-master},
          ).with_content(
            %r{include-pattern: slave-provide-xfr},
          )
        end
      end
      describe 'Change Defaults' do
        context 'masters' do
          let(:params) { { 'masters' => ['slave'] } }

          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).without_content(
              %r{include-pattern: master-master},
            ).with_content(
              %r{include-pattern: slave-master},
            )
          end
        end
        context 'provide_xfrs' do
          let(:params) { { 'provide_xfrs' => ['master'] } }

          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).with_content(
              %r{include-pattern: master-provide-xfr},
            ).without_content(
              %r{include-pattern: slave-provide-xfr},
            )
          end
        end
        context 'allow_notify_additions' do
          before(:each) { params.merge!(allow_notify_additions: ['extra_allow_notify']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).with_content(
              %r{include-pattern: extra_allow_notify-allow-notify-addition},
            )
          end
        end
        context 'send_notify_additions' do
          before(:each) { params.merge!(send_notify_additions: ['extra_notify']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).with_content(
              %r{include-pattern: extra_notify-send-notify-addition},
            )
          end
        end
        context 'zonefile' do
          before(:each) { params.merge!(zonefile: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).with_content(
              %r{zonefile:.+foobar},
            )
          end
        end
        context 'zone_dir' do
          before(:each) { params.merge!(zone_dir: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).with_content(
              %r{zonefile: "/foobar/example.com"},
            )
          end
        end
        context 'rrl_whitelist' do
          before(:each) { params.merge!(rrl_whitelist: ['dnskey', 'rrsig']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat_fragment(
              'nsd_zones_example.com',
            ).without_content(
              %r{rrl-whitelist: nxdomain},
            ).with_content(
              %r{rrl-whitelist: rrsig},
            ).with_content(
              %r{rrl-whitelist: dnskey},
            )
          end
        end
      end
      describe 'Check bad params' do
        context 'masters' do
          let(:params) { { masters: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'masters server not defined' do
          let(:params) { { masters: ['foo'] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'provide_xfrs server not defined' do
          let(:params) { { notify_addresses: ['foo'] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'allow_notify_additions' do
          let(:params) { { allow_notify: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'send_notify_additions' do
          let(:params) { { provide_xfr: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'zonefile' do
          let(:params) { { zones: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'zone_dir' do
          let(:params) { { zone_dir: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'rrl_whitelist bad type' do
          let(:params) { { rrl_whitelist: ['foo'] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'rrl_whitelist' do
          let(:params) { { rrl_whitelist: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
