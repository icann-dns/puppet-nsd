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
    end
  end
end
