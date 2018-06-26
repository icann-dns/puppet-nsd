# frozen_string_literal: true

require 'spec_helper'

describe 'nsd::remote' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  let(:title) { 'xfr.example.com' }
  let(:params) do
    {
      address4: '192.0.2.1',
      # :address6 => :undef,
      # :tsig_name => :undef,
      # :port => '53',
    }
  end
  let(:pre_condition) do
    'class {\'::nsd\':
      tsigs => { \'example_tsig\' => { \'data\' => \'AAAA\' } }
    }'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      case facts[:kernel]
      when 'Linux'
        let(:conf_dir) { '/etc/nsd' }
      else
        let(:conf_dir) { '/usr/local/etc/nsd' }
      end
      let(:conf_file) { "#{conf_dir}/nsd.conf" }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_concat__fragment(
            'nsd_pattern_xfr.example.com'
          ).with_target(conf_file).with_order('15').with_content(
            %r{
              pattern:\n
              \s+name:\sxfr.example.com-master\n
              \s+allow-notify:\s192.0.2.1\sNOKEY\n
              \s+request-xfr:\sAXFR\s192.0.2.1\sNOKEY\n
            }x
          ).with_content(
            %r{
              pattern:\n
              \s+name:\sxfr.example.com-provide-xfr\n
              \s+notify:\s192.0.2.1\sNOKEY\n
              \s+provide-xfr:\s192.0.2.1\sNOKEY\n
            }x
          ).with_content(
            %r{
              pattern:\n
              \s+name:\s+xfr.example.com-allow-notify-addition\n
              \s+allow-notify:\s192.0.2.1\sNOKEY\n
            }x
          ).with_content(
            %r{
              pattern:\n
              \s+name:\sxfr.example.com-send-notify-addition\n
              \s+notify:\s192.0.2.1\sNOKEY\n
            }x
          )
        end
      end
      describe 'Change Defaults' do
        context 'ipv4 cidr only' do
          before { params.merge!(address4: '192.0.2.0/24') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s192.0.2.0/24\sNOKEY\n
              }x
            ).without_content(
              %r{request-xfr: AXFR 192.0.2.0/24}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+provide-xfr:\s192.0.2.0/24\sNOKEY\n
              }x
            ).without_content(
              %r{\s+notify: 192.0.2.0/24 NOKEY}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s192.0.2.0/24\sNOKEY\n
              }x
            ).with_content(
              %r{pattern:\s+name: xfr.example.com-send-notify-addition}
            )
          end
        end
        context 'ipv6 only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::1') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s2001:DB8::1\sNOKEY\n
                \s+request-xfr:\sAXFR\s2001:DB8::1\sNOKEY\n
                }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+notify:\s2001:DB8::1\sNOKEY\n
                \s+provide-xfr:\s2001:DB8::1\sNOKEY
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s2001:DB8::1\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-send-notify-addition\n
                \s+notify:\s2001:DB8::1\sNOKEY\n
              }x
            )
          end
        end
        context 'ipv6 cidr only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::/48') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s2001:DB8::/48\sNOKEY\n
              }x
            ).without_content(
              %r{request-xfr: AXFR 2001:DB8::/48}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+provide-xfr:\s2001:DB8::/48\sNOKEY\n
              }x
            ).without_content(
              %r{\s+notify: 2001:DB8::/48 NOKEY}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s2001:DB8::/48\sNOKEY\n
              }x
            ).with_content(
              %r{pattern:\s+name: xfr.example.com-send-notify-addition}
            )
          end
        end
        context 'ipv4 and ipv6' do
          before { params.merge!(address6: '2001:DB8::1') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s192.0.2.1\sNOKEY\n
                \s+request-xfr:\sAXFR\s192.0.2.1\sNOKEY\n
                \s+allow-notify:\s2001:DB8::1\sNOKEY\n
                \s+request-xfr:\sAXFR\s2001:DB8::1\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+notify:\s192.0.2.1\sNOKEY\n
                \s+provide-xfr:\s192.0.2.1\sNOKEY
                \s+notify:\s2001:DB8::1\sNOKEY\n
                \s+provide-xfr:\s2001:DB8::1\sNOKEY
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s192.0.2.1\sNOKEY\n
                \s+allow-notify:\s2001:DB8::1\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-send-notify-addition\n
                \s+notify:\s192.0.2.1\sNOKEY\n
                \s+notify:\s2001:DB8::1\sNOKEY\n
              }x
            )
          end
        end
        context 'ipv4 and ipv6 cidr' do
          before do
            params.merge!(address4: '192.0.2.0/24', address6: '2001:DB8::/48')
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s192.0.2.0/24\sNOKEY\n
                \s+allow-notify:\s2001:DB8::/48\sNOKEY\n
              }x
            ).without_content(
              %r{request-xfr: AXFR 2001:DB8::/48}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+provide-xfr:\s192.0.2.0/24\sNOKEY\n
                \s+provide-xfr:\s2001:DB8::/48\sNOKEY\n
              }x
            ).without_content(
              %r{\s+notify: 192.0.2.0/24 NOKEY}
            ).without_content(
              %r{\s+notify: 2001:DB8::/48 NOKEY}
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s192.0.2.0/24\sNOKEY\n
                \s+allow-notify:\s2001:DB8::/48\sNOKEY\n
              }x
            ).with_content(
              %r{pattern:\s+name: xfr.example.com-send-notify-addition}
            )
          end
        end
        context 'tsig_name' do
          before { params.merge!(tsig_name: 'example_tsig') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s192.0.2.1\sNOKEY\n
                \s+request-xfr:\sAXFR\s192.0.2.1\sexample_tsig\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+notify:\s192.0.2.1\sNOKEY\n
                \s+provide-xfr:\s192.0.2.1\sexample_tsig\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\s+xfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s192.0.2.1\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-send-notify-addition\n
                \s+notify:\s192.0.2.1\sNOKEY\n
              }x
            )
          end
        end
        context 'port' do
          before { params.merge!(port: 5353) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'nsd_pattern_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-master\n
                \s+allow-notify:\s192.0.2.1@5353\sNOKEY\n
                \s+request-xfr:\sAXFR\s192.0.2.1@5353\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-provide-xfr\n
                \s+notify:\s192.0.2.1@5353\sNOKEY\n
                \s+provide-xfr:\s192.0.2.1@5353\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\s+xfr.example.com-allow-notify-addition\n
                \s+allow-notify:\s192.0.2.1@5353\sNOKEY\n
              }x
            ).with_content(
              %r{
                pattern:\n
                \s+name:\sxfr.example.com-send-notify-addition\n
                \s+notify:\s192.0.2.1@5353\sNOKEY\n
              }x
            )
          end
        end
      end
      describe 'check bad type' do
        context 'address4' do
          before { params.merge!(address4: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'address4' do
          before { params.merge!(address4: '333.333.333.333') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'address6' do
          before { params.merge!(address6: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tsig_name' do
          before { params.merge!(tsig_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'port' do
          before { params.merge!(port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
