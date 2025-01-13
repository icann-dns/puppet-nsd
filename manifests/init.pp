# @summary Configure NSD authoritative DNS server
# @param tcp_timeout TCP timeout in seconds
# @param statistics Interval in seconds for statistics
# @param chroot Directory to chroot to
# @param logfile Path to the log file
# @param difffile Path to the differences file
# @param control_interface IP address for control interface
# @param database Path to the database file
# @param default_tsig_name Default TSIG key name
# @param default_masters List of default master servers
# @param default_provide_xfrs List of default servers to provide zone transfers
# @param enable Whether to enable the service
# @param slave_addresses Hash of slave addresses
# @param zones Hash of DNS zones
# @param files Hash of files to manage
# @param tsigs Hash of TSIG keys
# @param remotes Hash of remote servers
# @param server_template Template for server configuration
# @param zones_template Template for zones configuration
# @param pattern_template Template for patterns configuration
# @param gather_template Template for gather configuration
# @param includes_template Template for includes configuration
# @param puppetdb_server IP address of the PuppetDB server
# @param puppetdb_port Port of the PuppetDB server
# @param ip_addresses List of IP addresses
# @param includes List of include files
# @param ip_transparent Whether to enable IP transparency
# @param reuseport Whether to enable SO_REUSEPORT
# @param debug_mode Whether to enable debug mode
# @param tcp_count Number of TCP connections
# @param tcp_query_count Number of TCP queries
# @param ipv4_edns_size EDNS buffer size for IPv4
# @param ipv6_edns_size EDNS buffer size for IPv6
# @param port Port number for the DNS server
# @param username Username to run the service as
# @param xfrd_reload_timeout Timeout for XFRD reload
# @param verbosity Verbosity level
# @param hide_version Whether to hide the version
# @param version Version string
# @param control_enable Whether to enable control interface
# @param control_port Port number for control interface
# @param logrotate_rotate Number of log rotations
# @param logrotate_size Size of log files for rotation
# @param rrl_enable Whether to enable Response Rate Limiting
# @param rrl_size Size of the RRL table
# @param rrl_ratelimit Rate limit for RRL
# @param rrl_slip Slip ratio for RRL
# @param rrl_whitelist List of whitelisted IPs for RRL
# @param rrl_ipv4_prefix_length IPv4 prefix length for RRL
# @param rrl_ipv6_prefix_length IPv6 prefix length for RRL
# @param rrl_whitelist_ratelimit Rate limit for whitelisted IPs in RRL
# @param identity Identity string
# @param nsid NSID string
# @param server_count Number of server instances
# @param pidfile Path to the PID file
# @param zonesdir Directory for zone files
# @param conf_dir Directory for configuration files
# @param zone_subdir Subdirectory for zone files
# @param conf_file Path to the main configuration file
# @param xfrdfile Path to the XFRD state file
# @param server_key_file Path to the server key file
# @param server_cert_file Path to the server certificate file
# @param control_key_file Path to the control key file
# @param control_cert_file Path to the control certificate file
# @param package_name Name of the package
# @param service_name Name of the service
# @param restart_cmd Command to restart the service
# @param logrotate_enable Whether to enable log rotation
# @param default_allow_axfr_fallback Default allow AXFR fallback
# @param default_create_ixfr Default create IXFR
# @param default_ixfr_size Default IXFR size
# @param imports List of import files
# @param exports List of export files
class nsd (
  Optional[Integer]             $tcp_timeout                 = undef,
  Optional[Integer]             $statistics                  = undef,
  Optional[Stdlib::Unixpath]    $chroot                      = undef,
  Optional[Stdlib::Unixpath]    $logfile                     = undef,
  Optional[Stdlib::Unixpath]    $difffile                    = undef,
  Optional[Stdlib::IP::Address] $control_interface           = undef,
  Optional[Stdlib::Unixpath]    $database                    = undef,
  String                        $default_tsig_name           = 'NOKEY',
  Array[String]                 $default_masters             = [],
  Array[String]                 $default_provide_xfrs        = [],
  Boolean                       $enable                      = true,
  Hash                          $slave_addresses             = {},
  Hash                          $zones                       = {},
  Hash                          $files                       = {},
  Hash                          $tsigs                       = {},
  Hash                          $remotes                     = {},
  String                        $server_template             = 'nsd/etc/nsd/nsd.server.conf.erb',
  String                        $zones_template              = 'nsd/etc/nsd/nsd.zones.conf.erb',
  String                        $pattern_template            = 'nsd/etc/nsd/nsd.patterns.conf.erb',
  String                        $gather_template             = 'nsd/etc/nsd/nsd.gather.conf.erb',
  String                        $includes_template           = 'nsd/etc/nsd/nsd.includes.conf.erb',
  Stdlib::IP::Address           $puppetdb_server             = '127.0.0.1',
  Stdlib::Port                  $puppetdb_port               = 8080,
  Array[Stdlib::IP::Address]    $ip_addresses                = [],
  Array[String[1]]              $includes                    = [],
  Boolean                       $ip_transparent              = false,
  Boolean                       $reuseport                   = false,
  Boolean                       $debug_mode                  = false,
  Integer                       $tcp_count                   = 250,
  Integer                       $tcp_query_count             = 0,
  Integer[512,4096]             $ipv4_edns_size              = 4096,
  Integer[512,4096]             $ipv6_edns_size              = 4096,
  Stdlib::Port                  $port                        = 53,
  String                        $username                    = 'nsd',
  Integer                       $xfrd_reload_timeout         = 1,
  Integer[0,3]                  $verbosity                   = 0,
  Boolean                       $hide_version                = false,
  Optional[String]              $version                     = undef,
  Boolean                       $control_enable              = false,
  Stdlib::Port                  $control_port                = 8952,
  Integer                       $logrotate_rotate            = 5,
  String                        $logrotate_size              = '100M',
  Boolean                       $rrl_enable                  = true,
  Integer                       $rrl_size                    = 1000000,
  Integer                       $rrl_ratelimit               = 200,
  Integer                       $rrl_slip                    = 2,
  Array[String]                 $rrl_whitelist               = [],
  Integer[1,32]                 $rrl_ipv4_prefix_length      = 24,
  Integer[1,128]                $rrl_ipv6_prefix_length      = 64,
  Integer                       $rrl_whitelist_ratelimit     = 4000,
  String                        $identity                    = $facts['networking']['fqdn'],
  String                        $nsid                        = $facts['networking']['fqdn'],
  Integer[1,255]                $server_count                = $facts['processors']['count'],
  Stdlib::Unixpath              $pidfile                     = '/run/nsd/nsd.pid',
  Stdlib::Unixpath              $zonesdir                    = '/var/lib/nsd',
  Stdlib::Unixpath              $conf_dir                    = '/etc/nsd',
  Stdlib::Unixpath              $zone_subdir                 = "${zonesdir}/zone",
  Stdlib::Unixpath              $conf_file                   = "${conf_dir}/nsd.conf",
  Stdlib::Unixpath              $xfrdfile                    = "${zonesdir}/xfrd.state",
  Stdlib::Unixpath              $server_key_file             = "${conf_dir}/nsd_server.key",
  Stdlib::Unixpath              $server_cert_file            = "${conf_dir}/nsd_server.pem",
  Stdlib::Unixpath              $control_key_file            = "${conf_dir}/nsd_control.key",
  Stdlib::Unixpath              $control_cert_file           = "${conf_dir}/nsd_control.pem",
  String                        $package_name                = 'nsd',
  String                        $service_name                = 'nsd',
  String                        $restart_cmd                 = '/usr/sbin/nsd-control reconfig',
  Boolean                       $logrotate_enable            = true,
  Optional[Stdlib::Yes_no]      $default_allow_axfr_fallback = undef,
  Optional[Stdlib::Yes_no]      $default_create_ixfr         = undef,
  Optional[Integer]             $default_ixfr_size           = undef,
  Array[String]                 $imports                     = [],
  Array[String]                 $exports                     = [],
) {
  # TODO: We should add this to the systemd unit file
  $_restart_cmd = "${restart_cmd} || nsd-checkconf ${conf_file} && service nsd restart"
  ensure_packages([$package_name])

  group { 'nsd':
    ensure => present,
    system => true,
  }
  user { 'nsd':
    ensure => present,
    home   => '/var/lib/nsd',
    shell  => '/usr/sbin/nologin',
    gid    => 'nsd',
    system => true,
  }
  file {
    default:
      ensure => directory,
      owner  => $username,
      group  => $username,
      before => Package[$package_name];
    [$zonesdir, $zone_subdir]:
      ;
    $conf_dir:
      mode  => '0755',
      owner => 'root';
  }
  concat { $conf_file:
    before  => Package[$package_name],
    require => File[$conf_dir],
    notify  => Service[$service_name];
  }
  concat::fragment { 'nsd_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '01',
  }
  concat::fragment { 'includes':
    target  => $conf_file,
    content => template($includes_template),
    order   => '19',
  }
  if $control_enable {
    exec { '/usr/sbin/nsd-control-setup':
      creates => $server_key_file,
      require => Package[$package_name],
    }
  }
  service { $service_name:
    ensure  => $enable,
    enable  => $enable,
    restart => $_restart_cmd,
    require => Package[$package_name];
  }
  if $logrotate_enable and $logfile {
    logrotate::rule { 'nsd':
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
  concat::fragment { 'nsd_pattern_gather':
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
