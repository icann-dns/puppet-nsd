require 'spec_helper_acceptance'

describe 'ssh::server class' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = 'class {\'::ssh::server\': }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
  end

  describe 'running puppet code with print_mod true' do
    it 'should work with no errors' do
      pp = 'class {\'::ssh::server\':  print_mod => true }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe 'ssh_config should contain PrintMotd yes' do
      describe file('/etc/ssh/sshd_config') do
        it { should be_file }
        its(:content) { should match /PrintMotd yes/ }
      end
    end
  end
end
