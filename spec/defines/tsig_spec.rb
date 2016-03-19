require 'spec_helper'

describe 'nsd::tsig', :type => :define do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:pre_condition) { ['include ::nsd'] }
      let(:title) { 'test' }
      describe 'basic check' do
        let(:params) {{ :data => 'aaaa' }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat_fragment('nsd_key_test').with_content(
          /name: test/
        ).with_content(
          /secret: aaaa/
        )}
      end

      describe 'Check bad params' do
        context 'algo' do
          let(:params) {{ :also => 'bla' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'data' do
          let(:params) {{ :data => true }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'template' do
          let(:params) {{ :template => 'foo' }}
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end

    end
  end
end
