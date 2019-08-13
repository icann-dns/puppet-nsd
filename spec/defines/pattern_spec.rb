# frozen_string_literal: true

require 'spec_helper'

describe 'nsd::pattern' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  let(:title) { 'example' }

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
      # rubocop:disable RSpec/ScatteredLet
      let(:conf_file) { "#{conf_dir}/nsd.conf" }

      # rubocop:enable RSpec/ScatteredLet

      describe 'check basic pattern creation' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
            %r{
              pattern:\n
              \s+name:\sexample\n
            }x,
          )
        end
      end
      describe 'nsd options' do
        context 'zonefile' do
          let(:params) do
            {
              zonefile: '/etc/nsd/primary/%1/%s',
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+zonefile:\s"/etc/nsd/primary/%1/%s"\n
            }x,
            )
          }
        end
        context 'allow-notify' do
          let(:params) do
            {
              allow_notifies: [
                {
                  address4: '127.0.0.1',
                  address6: '::1',
                  tsig_name: 'example_tsig',
                  port: 54,
                },
              ],
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+allow-notify:\s127.0.0.1@54\sexample_tsig\n
              \s+allow-notify:\s::1@54\sexample_tsig\n
            }x,
            )
          }
        end
        context 'request-xfr' do
          let(:params) do
            {
              request_xfrs: [
                {
                  address4: '127.0.0.1',
                  address6: '::1',
                  tsig_name: 'example_tsig',
                  port: 54,
                },
              ],
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+request-xfr:\s127.0.0.1@54\sexample_tsig\n
              \s+request-xfr:\s::1@54\sexample_tsig\n
            }x,
            )
          }
        end
        context 'allow-axfr-fallback' do
          let(:params) do
            {
              allow_axfr_fallback: true,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+allow-axfr-fallback:\syes\n
            }x,
            )
          }
        end
        context 'notify' do
          let(:params) do
            {
              notifies: [
                {
                  address4: '127.0.0.1',
                  address6: '::1',
                  tsig_name: 'example_tsig',
                  port: 54,
                },
              ],
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+notify:\s127.0.0.1@54\sexample_tsig\n
              \s+notify:\s::1@54\sexample_tsig\n
            }x,
            )
          }
        end
        context 'notify-retry' do
          let(:params) do
            {
              notify_retry: 200,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+notify-retry:\s200\n
            }x,
            )
          }
        end
        context 'provide-xfr' do
          let(:params) do
            {
              provide_xfrs: [
                {
                  address4: '127.0.0.1',
                  address6: '::1',
                  tsig_name: 'example_tsig',
                  port: 54,
                },
              ],
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+provide-xfr:\s127.0.0.1@54\sexample_tsig\n
              \s+provide-xfr:\s::1@54\sexample_tsig\n
            }x,
            )
          }
        end
        context 'outgoing-interface IPv4' do
          let(:params) do
            {
              outgoing_interface4: '127.0.0.1',
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+outgoing-interface:\s127.0.0.1\n
            }x,
            )
          }
        end
        context 'outgoing-interface IPv6' do
          let(:params) do
            {
              outgoing_interface6: '::1',
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+outgoing-interface:\s::1\n
            }x,
            )
          }
        end
        context 'max-refresh-time' do
          let(:params) do
            {
              max_refresh_time: 200,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+max-refresh-time:\s200\n
            }x,
            )
          }
        end
        context 'min-refresh-time' do
          let(:params) do
            {
              min_refresh_time: 200,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+min-refresh-time:\s200\n
            }x,
            )
          }
        end
        context 'max-retry-time' do
          let(:params) do
            {
              max_retry_time: 200,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+max-retry-time:\s200\n
            }x,
            )
          }
        end
        context 'min-retry-time' do
          let(:params) do
            {
              min_retry_time: 200,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+min-retry-time:\s200\n
            }x,
            )
          }
        end
        context 'zonestats' do
          let(:params) do
            {
              zonestats: '%s',
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+zonestats:\s"%s"\n
            }x,
            )
          }
        end
        context 'include-pattern' do
          let(:pre_condition) do
            'nsd::pattern {\'included-pattern\':}'
          end
          let(:params) do
            {
              include_patterns: ['included-pattern'],
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+include-pattern:\sincluded-pattern\n
            }x,
            )
          }
        end
        context 'multi-master-check' do
          let(:params) do
            {
              multi_master_check: true,
            }
          end

          it {
            is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('15').with_content(
              %r{
              pattern:\n
              \s+name:\sexample\n
              \s+multi-master-check:\syes\n
            }x,
            )
          }
        end
      end
      describe 'puppet options' do
        context 'order override' do
          let(:params) do
            {
              order: '20',
            }
          end

          it { is_expected.to contain_concat__fragment('nsd_pattern_example').with_target(conf_file).with_order('20') }
        end
      end
    end
  end
end
