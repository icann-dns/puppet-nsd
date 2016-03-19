require 'spec_helper_acceptance'

describe 'ssh::client class' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = 'class {\'::ssh::client\': }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe 'ssh_config should contain CheckHostIP no' do
      describe file('/etc/ssh/ssh_config') do
        it { should be_file }
        its(:content) { should_not match /\tCheckHostIP no/ }
      end
    end
  end

  describe 'running puppet code with check_host_ip false' do
    it 'should work with no errors' do
      pp = 'class {\'::ssh::client\':  check_host_ip => false }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe 'ssh_config should contain CheckHostIP no' do
      describe file('/etc/ssh/ssh_config') do
        it { should be_file }
        its(:content) { should match /CheckHostIP no/ }
      end
    end
  end
end
