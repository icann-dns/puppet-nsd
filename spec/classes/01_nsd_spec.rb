# frozen_string_literal: true

require 'spec_helper'
describe 'nsd', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:package_name)     { 'nsd' }
      let(:service_name)     { 'nsd' }
      let(:conf_dir)         { '/etc/nsd' }
      let(:zonesdir)         { '/var/lib/nsd' }
      let(:init)             { 'upstart' }
      let(:pidfile)          { '/run/nsd/nsd.pid' }
      let(:database)         { '""' }
      let(:xfrdfile)         { "#{zonesdir}/xfrd.state" }
      let(:conf_file)        { "#{conf_dir}/nsd.conf" }
      let(:logrotate_enable) { true }
      let(:zone_subdir) { "#{zonesdir}/zone" }

      describe 'check default config' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('nsd') }
        it { is_expected.to contain_package(package_name).with_ensure('installed') }
        it { is_expected.to contain_concat(conf_file) }

        it do
          is_expected.to contain_concat_fragment(
            'nsd_server'
          ).with_target(
            conf_file
          ).with_content(
            %r{ip-transparent: no}
          ).with_content(
            %r{debug-mode: no}
          ).with_content(
            %r{database: #{database}}
          ).with_content(
            %r{identity: foo.example.com}
          ).with_content(
            %r{nsid: "666f6f2e6578616d706c652e636f6d"}
          ).without_content(
            %r{logfile:}
          ).with_content(
            %r{server-count: #{facts[:processors]['count']}}
          ).with_content(
            %r{tcp-count: 250}
          ).with_content(
            %r{tcp-query-count: 0}
          ).without_content(
            %r{tcp-timeout:}
          ).with_content(
            %r{ipv4-edns-size: 4096}
          ).with_content(
            %r{ipv6-edns-size: 4096}
          ).with_content(
            %r{pidfile: #{pidfile}}
          ).with_content(
            %r{port: 53}
          ).without_content(
            %r{statistics:}
          ).without_content(
            %r{chroot:}
          ).with_content(
            %r{username: nsd}
          ).with_content(
            %r{zonesdir: #{zonesdir}}
          ).without_content(
            %r{difffile:}
          ).with_content(
            %r{xfrdfile: #{xfrdfile}}
          ).with_content(
            %r{xfrd-reload-timeout: 1}
          ).with_content(
            %r{verbosity: 0}
          ).with_content(
            %r{hide-version: no}
          ).with_content(
            %r{rrl-size: 1000000}
          ).with_content(
            %r{rrl-ratelimit: 200}
          ).with_content(
            %r{rrl-slip: 2}
          ).with_content(
            %r{rrl-ipv4-prefix-length: 24}
          ).with_content(
            %r{rrl-ipv6-prefix-length: 64}
          ).with_content(
            %r{rrl-whitelist-ratelimit: 4000}
          ).with_content(
            %r{control-enable: no}
          )
        end

        it do
          is_expected.to contain_file(zonesdir).with(
            ensure: 'directory',
            owner: 'nsd',
            group: 'nsd'
          )
        end

        it do
          is_expected.to contain_file(zone_subdir).with(
            ensure: 'directory',
            owner: 'nsd',
            group: 'nsd'
          )
        end

        it do
          is_expected.to contain_file(conf_dir).with(
            ensure: 'directory',
            mode: '0755',
            group: 'nsd'
          )
        end

        it do
          is_expected.to contain_service(service_name).with(
            ensure: true,
            enable: true
          )
        end
      end

      describe 'check changin default parameters' do
        context 'enable' do
          let(:params) { { enable: false } }

          it do
            is_expected.to contain_service(service_name).with(
              ensure: false,
              enable: false
            )
          end
        end

        context 'zones' do
          let(:params) do
            {
              remotes: {
                'test' => {
                  'address4' => '192.0.2.1',
                },
              },
              zones: {
                'test' => {
                  'masters' => ['test'],
                  'provide_xfrs' => ['test'],
                },
              },
            }
          end

          it do
            is_expected.to contain_nsd__zone('test').with(
              masters: ['test'],
              provide_xfrs: ['test']
            )
          end
        end

        context 'files' do
          let(:params) do
            {
              files: {
                'foo' => {
                  'source' => 'puppet:///modules/foo.zone',
                },
                'bar' => {
                  'content' => 'foo.zone',
                },
              },
            }
          end

          it do
            is_expected.to contain_nsd__file('foo').with_source(
              'puppet:///modules/foo.zone'
            )
          end

          it { is_expected.to contain_nsd__file('bar').with_content('foo.zone') }
        end

        context 'tsigs' do
          let(:params) do
            {
              tsigs: {
                'foo' => {
                  'data' => 'aaaa',
                },
              },
            }
          end

          it { is_expected.to contain_nsd__tsig('foo').with_data('aaaa') }
        end

        context 'ip_addresses' do
          let(:params) { { ip_addresses: ['192.0.2.1'] } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{ip-address: 192.0.2.1}
            )
          end
        end

        context 'includes' do
          let(:params) { { includes: ['/etc/nsd/foo/'] } }

          it do
            is_expected.to contain_concat_fragment('includes').with_content(
              %r{include: "/etc/nsd/foo/"}
            )
          end
        end

        context 'ip_transparent' do
          let(:params) { { ip_transparent: true } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{ip-transparent: yes}
            )
          end
        end

        context 'reuseport' do
          let(:params) { { reuseport: true } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{reuseport: yes}
            )
          end
        end

        context 'debug_mode' do
          let(:params) { { debug_mode: true } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{debug-mode: yes}
            )
          end
        end

        context 'identity' do
          let(:params) { { identity: 'foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{identity: foo}
            )
          end
        end

        context 'nsid' do
          let(:params) { { nsid: 'foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{nsid: "666f6f"}
            )
          end
        end

        context 'logfile' do
          let(:params) { { logfile: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{logfile: /foo}
            )
          end
        end

        context 'server_count' do
          let(:params) { { server_count: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{server-count: 6}
            )
          end
        end

        context 'tcp_count' do
          let(:params) { { tcp_count: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{tcp-count: 6}
            )
          end
        end

        context 'tcp_query_count' do
          let(:params) { { tcp_query_count: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{tcp-query-count: 6}
            )
          end
        end

        context 'tcp_timeout' do
          let(:params) { { tcp_timeout: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{tcp-timeout: 6}
            )
          end
        end

        context 'ipv4_edns_size' do
          let(:params) { { ipv4_edns_size: 512 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{ipv4-edns-size: 512}
            )
          end
        end

        context 'ipv6_edns_size' do
          let(:params) { { ipv6_edns_size: 512 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{ipv6-edns-size: 512}
            )
          end
        end

        context 'pidfile' do
          let(:params) { { pidfile: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{pidfile: /foo}
            )
          end
        end

        context 'port' do
          let(:params) { { port: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{port: 6}
            )
          end
        end

        context 'statistics' do
          let(:params) { { statistics: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{statistics: 6}
            )
          end
        end

        context 'chroot' do
          let(:params) { { chroot: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{chroot: /foo}
            )
          end
        end

        context 'username' do
          let(:params) { { username: 'foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{username: foo}
            )
          end
        end

        context 'zonesdir' do
          let(:params) { { zonesdir: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{zonesdir: /foo}
            )
          end
        end

        context 'difffile' do
          let(:params) { { difffile: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{difffile: /foo}
            )
          end
        end

        context 'xfrdfile' do
          let(:params) { { xfrdfile: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{xfrdfile: /foo}
            )
          end
        end

        context 'xfrd_reload_timeout' do
          let(:params) { { xfrd_reload_timeout: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{xfrd-reload-timeout: 6}
            )
          end
        end

        context 'verbosity' do
          let(:params) { { verbosity: 1 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{verbosity: 1}
            )
          end
        end

        context 'hide_version' do
          let(:params) { { hide_version: true } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{hide-version: yes}
            )
          end
        end

        context 'rrl_size' do
          let(:params) { { rrl_size: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-size: 6}
            )
          end
        end

        context 'rrl_ratelimit' do
          let(:params) { { rrl_ratelimit: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-ratelimit: 6}
            )
          end
        end

        context 'rrl_slip' do
          let(:params) { { rrl_slip: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-slip: 6}
            )
          end
        end

        context 'rrl_ipv4_prefix_length' do
          let(:params) { { rrl_ipv4_prefix_length: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-ipv4-prefix-length: 6}
            )
          end
        end

        context 'rrl_ipv6_prefix_length' do
          let(:params) { { rrl_ipv6_prefix_length: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-ipv6-prefix-length: 6}
            )
          end
        end

        context 'rrl_whitelist_ratelimit' do
          let(:params) { { rrl_whitelist_ratelimit: 6 } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{rrl-whitelist-ratelimit: 6}
            )
          end
        end

        context 'control_enable' do
          let(:params) { { control_enable: true } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{control-enable: yes}
            )
          end
        end

        context 'database' do
          let(:params) { { database: '/foo' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_content(
              %r{database: /foo}
            )
          end
        end

        context 'package_name' do
          let(:params) { { package_name: 'foo' } }

          it { is_expected.to contain_package('foo').with_ensure('installed') }
        end

        context 'service_name' do
          let(:params) { { service_name: 'foo' } }

          it { is_expected.to contain_service('foo') }
        end

        context 'conf_file' do
          let(:params) { { conf_file: '/foo.cfg' } }

          it do
            is_expected.to contain_concat_fragment('nsd_server').with_target(
              '/foo.cfg'
            )
          end
        end
      end
    end
  end
end
