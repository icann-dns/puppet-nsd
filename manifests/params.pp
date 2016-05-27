#== Class: nsd
#
class nsd::params {
  case $::operatingsystem {
    'ubuntu': {
      case $::lsbdistcodename {
        'precise': {
          $package_name     = 'nsd3'
          $service_name     = 'nsd3'
          $conf_dir         = '/etc/nsd3'
          $zonesdir         = '/var/lib/nsd3'
          $conf_file        = "${conf_dir}/nsd.conf"
          $database         = "${zonesdir}/nsd.db"
          $xfrdfile         = "${zonesdir}/xfrd.state"
          $init             = 'base'
          $pidfile          = '/run/nsd3/nsd.pid'
          $logrotate_enable = true
        }
        default: {
          $package_name     = 'nsd'
          $service_name     = 'nsd'
          $conf_dir         = '/etc/nsd'
          $zonesdir         = '/var/lib/nsd'
          $conf_file        = "${conf_dir}/nsd.conf"
          $database         = "${zonesdir}/nsd.db"
          $xfrdfile         = "${zonesdir}/xfrd.state"
          $init             = 'upstart'
          $pidfile          = '/run/nsd/nsd.pid'
          $logrotate_enable = true
        }
      }
    }
    'FreeBSD': {
      $package_name         = 'nsd'
      $service_name         = 'nsd'
      $conf_dir             = '/usr/local/etc/nsd'
      $zonesdir             = "${conf_dir}/data"
      $conf_file            = "${conf_dir}/nsd.conf"
      $database             = '/var/db/nsd/nsd.db'
      $xfrdfile             = '/var/db/nsd/xfrd.state'
      $init                 = 'freebsd'
      $pidfile              = '/var/run/nsd/nsd.pid'
      $logrotate_enable     = false
    }
    default: {
      $package_name         = 'nsd'
      $service_name         = 'nsd'
      $conf_dir             = '/etc/nsd'
      $zonesdir             = '/var/lib/nsd3/zone'
      $conf_file            = "${conf_dir}/nsd.conf"
      $database             = "${zonesdir}/nsd.db"
      $xfrdfile             = "${zonesdir}/xfrd.state"
      $init                 = 'base'
      $pidfile              = '/run/nsd3/nsd.pid'
      $logrotate_enable     = true
    }
  }
  #NSD config
  $identity                 = $::fqdn
  $nsid                     = $::fqdn
  $zone_subdir              = "${zonesdir}/zone"
  $server_count             = $::processorcount
  $server_key_file          = "${conf_dir}/server.key"
  $server_cert_file         = "${conf_dir}/server.pem"
  $control_key_file         = "${conf_dir}/control.key"
  $control_cert_file        = "${conf_dir}/control.pem"
}
