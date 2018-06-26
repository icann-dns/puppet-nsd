#== Class: nsd
#
class nsd::params {
  case $::osfamily {
    'Debian': {
      $restart_cmd = 'PATH=/usr/sbin/ nsd-control reconfig'
      case $::lsbdistcodename {
        'precise': {
          $package_name     = 'nsd3'
          $service_name     = 'nsd3'
          $conf_dir         = '/etc/nsd3'
          $zonesdir         = '/var/lib/nsd3'
          $conf_file        = "${conf_dir}/nsd.conf"
          $xfrdfile         = "${zonesdir}/xfrd.state"
          $database         = "${zonesdir}/nsd.db"
          $init             = 'base'
          $pidfile          = '/run/nsd3/nsd.pid'
          $logrotate_enable = true
        }
        'trusty': {
          $package_name     = 'nsd'
          $service_name     = 'nsd'
          $conf_dir         = '/etc/nsd'
          $zonesdir         = '/var/lib/nsd'
          $conf_file        = "${conf_dir}/nsd.conf"
          $xfrdfile         = "${zonesdir}/xfrd.state"
          if defined('$::nsd_version') and versioncmp($::nsd_version, '4.1.0') >= 0 {
            $database         = undef
          } else {
            $database         = "${zonesdir}/nsd.db"
          }
          $init             = 'upstart'
          $pidfile          = '/run/nsd/nsd.pid'
          $logrotate_enable = true
        }
        default: {
          $package_name     = 'nsd'
          $service_name     = 'nsd'
          $conf_dir         = '/etc/nsd'
          $zonesdir         = '/var/lib/nsd'
          $conf_file        = "${conf_dir}/nsd.conf"
          $xfrdfile         = "${zonesdir}/xfrd.state"
          $database         = undef
          $init             = 'upstart'
          $pidfile          = '/run/nsd/nsd.pid'
          $logrotate_enable = true
        }
      }
    }
    'FreeBSD': {
      $restart_cmd          = 'PATH=/usr/local/sbin/ nsd-control reconfig'
      $package_name         = 'nsd'
      $service_name         = 'nsd'
      $conf_dir             = '/usr/local/etc/nsd'
      $zonesdir             = "${conf_dir}/data"
      $conf_file            = "${conf_dir}/nsd.conf"
      $database             = undef
      $xfrdfile             = '/var/db/nsd/xfrd.state'
      $init                 = 'freebsd'
      $pidfile              = '/var/run/nsd/nsd.pid'
      $logrotate_enable     = false
    }
    'RedHat': {
      $restart_cmd          = 'PATH=/usr/sbin/ nsd-control reconfig'
      $zonesdir             = '/var/lib/nsd'
      $database             = "${zonesdir}/nsd.db"
      $pidfile              = '/run/nsd/nsd.pid'
      $package_name         = 'nsd'
      $service_name         = 'nsd'
      $conf_dir             = '/etc/nsd'
      $conf_file            = "${conf_dir}/nsd.conf"
      $xfrdfile             = "${zonesdir}/xfrd.state"
      $init                 = undef
      $logrotate_enable     = true
    }
    default: {
      $restart_cmd          = 'PATH=/usr/sbin/ nsd-control reconfig'
      $zonesdir             = '/var/lib/nsd'
      $database             = "${zonesdir}/nsd.db"
      $pidfile              = '/run/nsd/nsd.pid'
      $package_name         = 'nsd'
      $service_name         = 'nsd'
      $conf_dir             = '/etc/nsd'
      $conf_file            = "${conf_dir}/nsd.conf"
      $xfrdfile             = "${zonesdir}/xfrd.state"
      $init                 = undef
      $logrotate_enable     = true
    }
  }
  #NSD config
  $identity                 = $::fqdn
  $nsid                     = $::fqdn
  $zone_subdir              = "${zonesdir}/zone"
  $server_count             = $facts['processors']['count']
  $server_key_file          = "${conf_dir}/nsd_server.key"
  $server_cert_file         = "${conf_dir}/nsd_server.pem"
  $control_key_file         = "${conf_dir}/nsd_control.key"
  $control_cert_file        = "${conf_dir}/nsd_control.pem"
}
