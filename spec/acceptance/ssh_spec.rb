require 'spec_helper_acceptance'

describe 'ssh class' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = 'class {\'::ssh\': }'
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
  end
end
