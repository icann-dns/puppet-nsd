#== Class: nsd
#
class nsd (
  Optional[Integer]           $tcp_timeout                 = undef,
  Optional[Integer]           $statistics                  = undef,
  Optional[Tea::Absolutepath] $chroot                      = undef,
  Optional[Tea::Absolutepath] $logfile                     = undef,
  Optional[Tea::Absolutepath] $difffile                    = undef,
  Optional[Tea::Ip_address]   $control_interface           = undef,
  Optional[Tea::Absolutepath] $database                    = undef,
  String                      $default_tsig_name           = 'NOKEY',
  Array[String]               $default_masters             = [],
  Array[String]               $default_provide_xfrs        = [],
  Boolean                     $enable                      = true,
  Hash                        $slave_addresses             = {},
  Hash                        $zones                       = {},
  Hash                        $files                       = {},
  Hash                        $tsigs                       = {},
  Hash                        $remotes                     = {},
  String                      $server_template             = 'nsd/etc/nsd/nsd.server.conf.erb',
  String                      $zones_template              = 'nsd/etc/nsd/nsd.zones.conf.erb',
  String                      $pattern_template            = 'nsd/etc/nsd/nsd.patterns.conf.erb',
  String                      $gather_template             = 'nsd/etc/nsd/nsd.gather.conf.erb',
  String                      $includes_template           = 'nsd/etc/nsd/nsd.includes.conf.erb',
  Tea::Ip_address             $puppetdb_server             = '127.0.0.1',
  Tea::Port                   $puppetdb_port               = 8080,
  Array[Tea::Ip_address]      $ip_addresses                = [],
  Array[String[1]]            $includes                    = [],
  Boolean                     $ip_transparent              = false,
  Boolean                     $reuseport                   = false,
  Boolean                     $debug_mode                  = false,
  Integer                     $tcp_count                   = 250,
  Integer                     $tcp_query_count             = 0,
  Integer[512,4096]           $ipv4_edns_size              = 4096,
  Integer[512,4096]           $ipv6_edns_size              = 4096,
  Tea::Port                   $port                        = 53,
  String                      $username                    = 'nsd',
  Integer                     $xfrd_reload_timeout         = 1,
  Integer[0,3]                $verbosity                   = 0,
  Boolean                     $hide_version                = false,
  Optional[String]            $version                     = undef,
  Boolean                     $control_enable              = false,
  Tea::Port                   $control_port                = 8952,
  Integer                     $logrotate_rotate            = 5,
  String                      $logrotate_size              = '100M',
  Boolean                     $rrl_enable                  = true,
  Integer                     $rrl_size                    = 1000000,
  Integer                     $rrl_ratelimit               = 200,
  Integer                     $rrl_slip                    = 2,
  Array[String]               $rrl_whitelist               = [],
  Integer[1,32]               $rrl_ipv4_prefix_length      = 24,
  Integer[1,128]              $rrl_ipv6_prefix_length      = 64,
  Integer                     $rrl_whitelist_ratelimit     = 4000,
  String                      $identity                    = $facts['networking']['fqdn'],
  String                      $nsid                        = $facts['networking']['fqdn'],
  Integer[1,255]              $server_count                = $facts['processors']['count'],
  Tea::Absolutepath           $pidfile                     = '/run/nsd/nsd.pid',
  Tea::Absolutepath           $zonesdir                    = '/var/lib/nsd',
  Tea::Absolutepath           $conf_dir                    = '/etc/nsd',
  Tea::Absolutepath           $zone_subdir                 = "${zonesdir}/zone",
  Tea::Absolutepath           $conf_file                   = "${conf_dir}/nsd.conf",
  Tea::Absolutepath           $xfrdfile                    = "${zonesdir}/xfrd.state"
  Tea::Absolutepath           $server_key_file             = "${conf_dir}/nsd_server.key",
  Tea::Absolutepath           $server_cert_file            = "${conf_dir}/nsd_server.pem",
  Tea::Absolutepath           $control_key_file            = "${conf_dir}/nsd_control.key",
  Tea::Absolutepath           $control_cert_file           = "${conf_dir}/nsd_control.pem",
  Optional[String]            $init                        = 'systemd'
  String                      $package_name                = 'nsd',
  String                      $service_name                = 'nsd',
  String                      $restart_cmd                 = '/usr/sbin/nsd-control reconfig'
  Boolean                     $logrotate_enable            = true,
  Optional[Stdlib::Yes_no]    $default_allow_axfr_fallback = undef,
  Optional[Stdlib::Yes_no]    $default_create_ixfr         = undef,
  Optional[Integer]           $default_ixfr_size           = undef,
  Array[String]               $imports                     = [],
  Array[String]               $exports                     = [],
) {

  $_restart_cmd = "${restart_cmd} || nsd-checkconf ${conf_file} && service nsd restart"
  ensure_packages([$package_name])
  concat{$conf_file:
    require => Package[$package_name],
    notify  => Service[$service_name];
  }
  concat::fragment{'nsd_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '01',
  }
  concat::fragment{'includes':
    target  => $conf_file,
    content => template($includes_template),
    order   => '19',
  }
  if $control_enable {
    exec { 'nsd-control-setup':
      command => 'nsd-control-setup',
      path    => '/usr/bin:/usr/sbin:/usr/local/sbin',
      creates => $server_key_file,
      require => Package[$package_name],
    }
  }
  file { [$zonesdir, $zone_subdir]:
    ensure  => directory,
    owner   => $username,
    group   => $username,
    require => Package[$package_name],
  }
  file { $conf_dir:
    ensure  => directory,
    mode    => '0755',
    group   => $username,
    require => Package[$package_name],
  }
  if $init == 'base' {
    service { $service_name:
      ensure   => $enable,
      provider => 'base',
      restart  => $_restart_cmd,
      start    => "/etc/init.d/${service_name} start",
      stop     => "/etc/init.d/${service_name} stop",
      enable   => $enable,
      require  => Package[$package_name];
    }
  } else {
    if $::operatingsystem == 'ubuntu' and $::lsbdistcodename == 'trusty' {
      file { '/etc/init/nsd.conf':
        ensure => file,
        source => 'puppet:///modules/nsd/etc/init/nsd.conf',
        notify => Service[$service_name],
      }
    }
    service { $service_name:
      ensure  => $enable,
      enable  => $enable,
      restart => $_restart_cmd,
      require => Package[$package_name];
    }
  }
  if $logrotate_enable and $logfile and $::kernel != 'FreeBSD' {
    logrotate::rule {'nsd':
      path       => $logfile,
      rotate     => $logrotate_rotate,
      size       => $logrotate_size,
      compress   => true,
      postrotate => "/usr/sbin/service ${service_name} restart",
    }
  }

  create_resources(nsd::file, $files)
  create_resources(nsd::tsig, $tsigs)
  if ! defined(Nsd::Tsig[$default_tsig_name]) and $default_tsig_name != 'NOKEY' {
    fail("Nsd::Tsig['${default_tsig_name}'] does not exist")
  }
  create_resources(nsd::remote, $remotes)
  concat::fragment {'nsd_pattern_gather':
    target  => $conf_file,
    content => template($gather_template),
    order   => '16',
  }
  $default_masters.each |String $master| {
    if ! defined(Nsd::Remote[$master]) {
      fail("Nsd::Remote['${master}'] does not exist but defined as default master")
    }
  }
  $default_provide_xfrs.each |String $provider_xfr| {
    if ! defined(Nsd::Remote[$provider_xfr]) {
      fail("Nsd::Remote['${provider_xfr}'] does not exist but defined as default provide xfr")
    }
  }
  create_resources(nsd::zone, $zones)
}
