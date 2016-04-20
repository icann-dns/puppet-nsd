require 'spec_helper_acceptance'

describe 'nsd class' do
  context 'running puppet with defaults' do
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
end
