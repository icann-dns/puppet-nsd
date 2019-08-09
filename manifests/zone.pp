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
) {
  include ::nsd
  $default_masters      = $nsd::default_masters
  $default_provide_xfrs = $nsd::default_provide_xfrs
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
  $masters.each |String $server| {
    if ! defined(Nsd::Remote[$server]) {
      fail("${name} defines master ${server}. however Nsd::Remote[${server}] is not defined")
    }
  }
  $provide_xfrs.each |String $server| {
    if ! defined(Nsd::Remote[$server]) {
      fail("${name} defines provide_xfr ${server}. however Nsd::Remote[${server}] is not defined")
    }
  }
  $allow_notify_additions.each |String $server| {
    if ! defined(Nsd::Remote[$server]) {
      fail("${name} defines allow_notify_addition ${server}. however Nsd::Remote[${server}] is not defined")
    }
  }
  $send_notify_additions.each |String $server| {
    if ! defined(Nsd::Remote[$server]) {
      fail("${name} defines send_notify_addition ${server}. however Nsd::Remote[${server}] is not defined")
    }
  }

  concat::fragment{ "nsd_zones_${name}":
    target  => $::nsd::conf_file,
    content => template($::nsd::zones_template),
    order   => 20;
  }
}
