#== Class: nsd
#
class nsd (
  $enable                   = true,
  $tsig                     = {},
  $slave_addresses          = {},
  $zones                    = {},
  $files                    = {},
  $tsigs                    = {},
  $server_template          = 'nsd/etc/nsd/nsd.server.conf.erb',
  $zones_template           = 'nsd/etc/nsd/nsd.zones.conf.erb',
  $ip_addresses             = [],
  $ip_transparent           = false,
  $debug_mode               = false,
  $identity                 = $::nsd::params::identity,
  $nsid                     = $::nsd::params::nsid,
  $logfile                  = undef,
  $server_count             = $::nsd::params::server_count,
  $tcp_count                = 250,
  $tcp_query_count          = 0,
  $tcp_timeout              = undef,
  $ipv4_edns_size           = 4096,
  $ipv6_edns_size           = 4096,
  $pidfile                  = $::nsd::params::pidfile,
  $port                     = 53,
  $statistics               = undef,
  $chroot                   = undef,
  $username                 = 'nsd',
  $zonesdir                 = $::nsd::params::zonesdir,
  $difffile                 = undef,
  $xfrdfile                 = $::nsd::params::xfrdfile,
  $xfrd_reload_timeout      = 1,
  $verbosity                = 0,
  $hide_version             = false,
  $rrl_size                 = 1000000,
  $rrl_ratelimit            = 200,
  $rrl_slip                 = 2,
  $rrl_ipv4_prefix_length   = 24,
  $rrl_ipv6_prefix_length   = 64,
  $rrl_whitelist_ratelimit  = 4000,
  $rrl_whitelist            = [],
  $control_enable           = false,
  $control_interface        = undef,
  $control_port             = 8952,
  $server_key_file          = $::nsd::params::server_key_file,
  $server_cert_file         = $::nsd::params::server_cert_file,
  $control_key_file         = $::nsd::params::control_key_file,
  $control_cert_file        = $::nsd::params::control_cert_file,
  $init                     = $::nsd::params::init,
  $database                 = $::nsd::params::database,
  $package_name             = $::nsd::params::package_name,
  $service_name             = $::nsd::params::service_name,
  $conf_dir                 = $::nsd::params::conf_dir,
  $zone_subdir              = $::nsd::params::zone_subdir,
  $conf_file                = $::nsd::params::conf_file,
  $manage_nagios            = false,
  $logrotate_enable         = $::nsd::params::logrotate_enable,
  $logrotate_rotate         = 5,
  $logrotate_size           = '100M',
) inherits nsd::params  {

  validate_bool($enable)
  validate_hash($tsig)
  validate_hash($slave_addresses)
  validate_hash($zones)
  validate_hash($files)
  validate_hash($tsigs)
  validate_bool($logrotate_enable)
  validate_integer($logrotate_rotate)
  validate_string($logrotate_size)
  validate_string($package_name)
  validate_string($service_name)
  validate_absolute_path($conf_dir)
  validate_absolute_path($zone_subdir)
  validate_absolute_path($conf_file)
  validate_string($init)
  validate_string($server_template)
  validate_string($zones_template)
  validate_array($ip_addresses)
  validate_bool($ip_transparent)
  validate_bool($debug_mode)
  validate_absolute_path($database)
  if $identity {
    validate_string($identity)
  }
  if $nsid {
    validate_string($nsid)
  }
  if $logfile {
    validate_absolute_path($logfile)
  }
  validate_integer($server_count)
  validate_integer($tcp_count)
  validate_integer($tcp_query_count)
  if $tcp_timeout {
    validate_integer($tcp_timeout)
  }
  validate_integer($ipv4_edns_size, 4096)
  validate_integer($ipv6_edns_size, 4096)
  validate_absolute_path($pidfile)
  validate_integer($port, 65535)
  if $statistics {
    validate_integer($statistics)
  }
  if $chroot {
    validate_absolute_path($chroot)
  }
  validate_string($username)
  if $zonesdir {
    validate_absolute_path($zonesdir)
  }
  if $difffile {
    validate_absolute_path($difffile)
  }
  validate_absolute_path($xfrdfile)
  validate_integer($xfrd_reload_timeout)
  validate_integer($verbosity,2)
  validate_bool($hide_version)
  validate_integer($rrl_size)
  validate_integer($rrl_ratelimit)
  validate_integer($rrl_slip)
  validate_integer($rrl_ipv4_prefix_length,32)
  validate_integer($rrl_ipv6_prefix_length,128)
  validate_integer($rrl_whitelist_ratelimit)
  validate_array($rrl_whitelist)

  ensure_packages($package_name)
  validate_bool($control_enable)
  if $control_interface {
    validate_array($control_interface)
  }
  validate_integer($control_port, 65535)
  validate_absolute_path($server_key_file)
  validate_absolute_path($server_cert_file)
  validate_absolute_path($control_key_file)
  validate_absolute_path($control_cert_file)

  concat{$conf_file:
    require => Package[$package_name],
    notify  => Service[$service_name];
  }
  concat::fragment{'nsd_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '01',
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
      start    => "/etc/init.d/${service_name} start",
      stop     => "/etc/init.d/${service_name} stop",
      enable   => $enable,
      require  => Package[$package_name];
    }
  } else {
    if $::operatingsystem == 'ubuntu' {
      file { '/etc/init/nsd.conf':
        ensure => file,
        source => 'puppet:///modules/nsd/etc/init/nsd.conf',
        notify => Service[$service_name],
      }
    }
    service { $service_name:
      ensure  => $enable,
      enable  => $enable,
      require => Package[$package_name];
    }
  }
  if $logrotate_enable and $logfile and $::kenel != 'FreeBSD' {
    logrotate::rule {'nsd':
      path       => $logfile,
      rotate     => $logrotate_rotate,
      size       => $logrotate_size,
      compress   => true,
      postrotate => "/usr/sbin/service ${service_name} restart",
    }
  }
  #add backwords compatible
  if ! empty($tsig) {
    nsd::tsig {$tsig['name']:
      algo => $tsig['algo'],
      data => $tsig['data'],
    }
  }

  create_resources(nsd::file, $files)
  create_resources(nsd::tsig, $tsigs)
  create_resources(nsd::zone, $zones)
}
