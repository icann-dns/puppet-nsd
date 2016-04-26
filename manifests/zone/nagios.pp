# nsd::zone::nagios
#
define nsd::zone::nagios (
  $slaves  = [],
  $masters = [],
) {
  validate_array($slaves)
  validate_array($masters)
  $_masters = delete($masters,['127.0.0.1','0::1'])
  $_slaves  = delete($slaves,['127.0.0.1','0::1'])
  if $_masters {
    $check_args = join($_masters, ' ')
    @@nagios_service{ "${::fqdn}_DNS_ZONE_MASTERS_${name}":
      ensure              => present,
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => "DNS_ZONE_MASTERS_${name}",
      check_command       => "check_nrpe_args!check_dns!${name}!${check_args}",
    }
  }
  if $_slaves {
    $check_args = join($_slaves, ' ')
    @@nagios_service{ "${::fqdn}_DNS_ZONE_SLAVES_${name}":
      ensure              => present,
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => "DNS_ZONE_MASTERS_${name}",
      check_command       => "check_nrpe_args!check_dns!${name}!${check_args}",
    }
  }

}
