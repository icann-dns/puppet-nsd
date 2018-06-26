# frozen_string_literal: true

require 'spec_helper'

describe 'nsd::file', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:pre_condition) { ['include ::nsd'] }
      let(:title) { 'test' }

      describe 'basic check' do
        let(:params) { { source: 'puppet:///modules/source' } }

        it { is_expected.to compile.with_all_deps }
      end
      describe 'Check bad params' do
        context 'owner' do
          let(:params) { { owner: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'group' do
          let(:params) { { group: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'mode' do
          let(:params) { { allow_notify: 'foo' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'source' do
          let(:params) { { source: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'content' do
          let(:params) { { content: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'ensure' do
          let(:params) { { ensure: true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
