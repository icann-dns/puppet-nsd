# frozen_string_literal: true

# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker(modules: :metadata)
hosts.each do |host|
  host.install_package('dnsutils')
end
Dir['./spec/support/acceptance/**/*.rb'].sort.each { |f| require f }
