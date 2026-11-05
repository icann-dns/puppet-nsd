# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'nsd class' do
  let(:ip) { fact('networking.ip') }
  let(:root_zone) do
    <<~EOS
      '.':
        masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'],
        zonefile => 'root';
    EOS
  end
  let(:pp) do
    <<~EOS
      class {'::nsd':
          remotes => {
            'lax.xfr.dns.icann.org' => {
              'address4' => '192.0.32.132'
            },
            'iad.xfr.dns.icann.org' => {
              'address4' => '192.0.47.132'
            },
          },
          rrl_whitelist => ['nxdomain', 'referral']
      }
      nsd::zone {
        #{root_zone}
        'arpa.':
          masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'];
        'root-servers.net.':
          masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'];
      }
    EOS
  end

  context 'root' do
    it 'work with no errors' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
      # sleep to allow zone transfer (value probably to high)
      sleep(10)
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

    %w[. arpa. root-servers.net.].each do |zone|
      describe zone do
        it 'returns the SOA' do
          result = command("dig +short soa #{zone} @#{ip}")
          expect(result.exit_status).to eq 0
          expect(result.stdout).to match %r{a.root-servers.net. nstld.verisign-grs.com.}
        end
      end
    end
  end
end
