require 'spec_helper_acceptance'

describe 'nsd class' do
  context 'defaults' do
    it 'should work with no errors' do
      pp = 'class {\'::nsd\': }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe service('nsd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
    describe port(53) do 
      it { is_expected.to be_listening }
    end
  end
  context 'as112' do
    it 'should work with no errors' do
      pp = <<-EOS
  class {'::nsd': }
  nsd::zone {
      'rfc1918':
        zonefile => 'db.dd-empty',
        zones => [
          '10.in-addr.arpa',
          '16.172.in-addr.arpa',
          '17.172.in-addr.arpa',
          '18.172.in-addr.arpa',
          '19.172.in-addr.arpa',
          '20.172.in-addr.arpa',
          '21.172.in-addr.arpa',
          '22.172.in-addr.arpa',
          '23.172.in-addr.arpa',
          '24.172.in-addr.arpa',
          '25.172.in-addr.arpa',
          '26.172.in-addr.arpa',
          '27.172.in-addr.arpa',
          '28.172.in-addr.arpa',
          '29.172.in-addr.arpa',
          '30.172.in-addr.arpa',
          '31.172.in-addr.arpa',
          '168.192.in-addr.arpa',
          '254.169.in-addr.arpa'
        ];
      'empty.as112.arpa':
        zonefile => 'db.dr-empty',
        zones    => ['empty.as112.arpa'];
      'hostname.as112.net':
        zonefile => 'hostname.as112.net.zone',
        zones    =>  ['hostname.as112.net'];
      'hostname.as112.arpa':
        zonefile => 'hostname.as112.arpa.zone',
        zones    => ['hostname.as112.arpa'];
    }
  }
  nsd::file {
    'db.dd-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dd-empty';
    'db.dr-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dr-empty';
    'hostname.as112.net.zone':
      content => template('nsd/etc/nsd/hostname.as112.net.zone.erb');
    'hostname.as112.arpa.zone':
      content => template('nsd/etc/nsd/hostname.as112.arpa.zone.erb');
  }
      EOS
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe service('nsd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
    describe port(53) do 
      it { is_expected.to be_listening }
    end
  end
end
