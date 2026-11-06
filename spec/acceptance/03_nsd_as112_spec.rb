# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'nsd class' do
  let(:ip) { fact('networking.ip') }

  context 'as112' do
    it 'work with no errors' do
      pp = 'class {\'::nsd::as112\': }'
      apply_manifest(pp, catch_failures: true)
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end

    describe service('nsd') do
      it { is_expected.to be_running }
    end

    describe port(53) do
      it { is_expected.to be_listening.on(ip) }
    end

    describe command('nsd-checkconf /etc/nsd/nsd.conf || cat /etc/nsd/nsd.conf') do
      its(:stdout) { is_expected.to match %r{} }
    end

    describe 'dig +short soa empty.as112.arpa' do
      it 'returns the SOA' do
        result = command("dig +short soa empty.as112.arpa @#{ip}")
        expect(result.exit_status).to eq 0
        expect(result.stdout).to match %r{blackhole.as112.arpa. noc.dns.icann.org. 1 604800 60 604800 604800}
      end
    end

    %w[
      10 16.172 17.172 18.172 19.172 20.172 21.172 22.172 23.172 24.172
      25.172 26.172 27.172 28.172 29.172 30.172 31.172 168.192 254.169
    ].each do |zone|
      describe zone do
        it 'returns the SOA' do
          result = command("dig +short soa #{zone}.in-addr.arpa @#{ip}")
          expect(result.exit_status).to eq 0
          expect(result.stdout).to match %r{prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800}
        end
      end
    end
  end
end
