# frozen_string_literal: true

require 'spec_helper_acceptance'

if ENV['BEAKER_TESTMODE'] == 'apply'
  describe 'nsd class' do
    context 'defaults' do
      it 'work with no errors' do
        pp = 'include nsd'
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
        expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
      end
      describe service('nsd') do
        it { is_expected.to be_running }
      end
      describe port(53) do
        it { is_expected.to be_listening }
      end
      describe command('nsd-checkconf /etc/nsd/nsd.conf || cat /etc/nsd/nsd.conf'), if: os[:family] == 'ubuntu' do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('nsd-checkconf /usr/local/etc/nsd/nsd.conf || cat /usr/local/etc/nsd/nsd.conf'), if: os[:family] == 'freebsd' do
        its(:stdout) { is_expected.to match %r{} }
      end
    end
  end
end
