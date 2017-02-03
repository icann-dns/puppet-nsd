#== Class: nsd
#
define nsd::zone (
  Optional[Array[String]]       $masters                = [],
  Optional[Array[String]]       $provide_xfrs           = [],
  Optional[Array[String]]       $allow_notify_additions = [],
  Optional[Array[String]]       $send_notify_additions  = [],
  Optional[String]              $zonefile               = undef,
  Optional[Tea::Absolutepath]   $zone_dir               = undef,
  Optional[Array[Nsd::Rrltype]] $rrl_whitelist          = [],
  Optional[String]              $fetch_tsig_name        = undef,
  Optional[String]              $provide_tsig_name      = undef,
) {
  include ::nsd
  $servers = $::nsd::servers
  if $zone_dir {
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $::nsd::zone_subdir
  }
  if empty($rrl_whitelist) {
    $_rrl_whitelist = $::nsd::rrl_whitelist
  } else {
    $_rrl_whitelist = $rrl_whitelist
  }
  if $fetch_tsig_name {
    if defined(Nsd::Tsig[$fetch_tsig_name]) or $fetch_tsig_name == 'NOKEY' {
      $_fetch_tsig_name = $fetch_tsig_name
    } else {
      fail("Nsd::Tsig['${fetch_tsig_name}'] does not exist")
    }
  } else {
    $_fetch_tsig_name = $::nsd::fetch_tsig_name
  }
  if $provide_tsig_name {
    if defined(Nsd::Tsig[$provide_tsig_name]) or $provide_tsig_name == 'NOKEY' {
      $_provide_tsig_name = $provide_tsig_name
    } else {
      fail("Nsd::Tsig['${provide_tsig_name}'] does not exist")
    }
  } else {
    $_provide_tsig_name = $::nsd::provide_tsig_name
  }
  $masters.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines master ${server}.  however this has not been defined as an nsd::server")
    }
  }
  $provide_xfrs.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines provide_xfr ${server}.  however this has not been defined as an nsd::server")
    }
  }
  $allow_notify_additions.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines allow_notify_addition ${server}.  however this has not been defined as an nsd::server")
    }
  }
  $send_notify_additions.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines send_notify_addition ${server}.  however this has not been defined as an nsd::server")
    }
  }

  concat::fragment{ "nsd_zones_${name}":
    target  => $::nsd::conf_file,
    content => template($::nsd::zones_template),
    order   => 20;
  }
  #if $::nsd::manage_nagios {
  #  nsd::zone::nagios {$zones:
  #    masters => $masters,
  #    slaves  => $provide_xfr,
  #  }
  #}
}
