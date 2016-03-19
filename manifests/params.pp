#== Class: nsd
#
class nsd::params {
  case $::operatingsystem {
    'ubuntu': {
      case $::lsbdistcodename {
        'precise': {
          $nsd_package_name         = 'nsd3'
          $nsd_service_name         = 'nsd3'
          $nsd_conf_dir             = '/etc/nsd3'
          $zonesdir                 = '/var/lib/nsd3'
          $nsd_conf_file            = "${nsd_conf_dir}/nsd.conf"
          $database                 = "${zonesdir}/nsd.db"
          $xfrdfile                 = "${zonesdir}/xfrd.state"
          $init                     = 'base'
          $pidfile                  = '/run/nsd3/nsd.pid'
          $logrotate_enable         = true
        }
        default: {
          $nsd_package_name         = 'nsd'
          $nsd_service_name         = 'nsd'
          $nsd_conf_dir             = '/etc/nsd'
          $zonesdir                 = '/var/lib/nsd'
          $nsd_conf_file            = "${nsd_conf_dir}/nsd.conf"
          $database                 = "${zonesdir}/nsd.db"
          $xfrdfile                 = "${zonesdir}/xfrd.state"
          $init                     = 'upstart'
          $pidfile                  = '/run/nsd/nsd.pid'
          $logrotate_enable         = true
        }
      }
    }
    'FreeBSD': {
      $nsd_package_name         = 'nsd'
      $nsd_service_name         = 'nsd'
      $nsd_conf_dir             = '/usr/local/etc/nsd'
      $zonesdir                 = "${nsd_conf_dir}/data"
      $nsd_conf_file            = "${nsd_conf_dir}/nsd.conf"
      $database                 = '/var/db/nsd/nsd.db'
      $xfrdfile                 = '/var/db/nsd/xfrd.state'
      $init                     = 'freebsd'
      $pidfile                  = '/var/run/nsd/nsd.pid'
      $logrotate_enable         = false
    }
    default: {
      $nsd_package_name         = 'nsd'
      $nsd_service_name         = 'nsd'
      $nsd_conf_dir             = '/etc/nsd'
      $zonesdir                 = '/var/lib/nsd3/zone'
      $nsd_conf_file            = "${nsd_conf_dir}/nsd.conf"
      $database                 = "${zonesdir}/nsd.db"
      $xfrdfile                 = "${zonesdir}/xfrd.state"
      $init                     = 'base'
      $pidfile                  = '/run/nsd3/nsd.pid'
      $logrotate_enable         = true
    }
  }
  #NSD config
  $identity                 = $::fqdn
  $nsid                     = $::fqdn
  $zone_subdir              = "${zonesdir}/zone"
  $server_count             = $::processorcount
  $server_key_file          = "${nsd_conf_dir}/nsd_server.key"
  $server_cert_file         = "${nsd_conf_dir}/nsd_server.pem"
  $control_key_file         = "${nsd_conf_dir}/nsd_control.key"
  $control_cert_file        = "${nsd_conf_dir}/nsd_control.pem"
}
