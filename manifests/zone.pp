# @summary define for creating nsd zones
# @param masters the list of master servers for the zone
# @param provide_xfrs the list of servers to provide xfrs to
# @param allow_notify_additions the list of servers to allow notify additions from
# @param send_notify_additions the list of servers to send notify additions to
# @param zonefile the zone file to use
# @param zone_dir the directory to store the zone file in
# @param rrl_whitelist the list of rrl whitelist entries
# @param zonemd_verify whether to verify zonemd records
# @param zonemd_generate whether to generate zonemd records
# @param allow_axfr_fallback whether to allow axfr fallback
# @param create_ixfr whether to create ixfr files
# @param ixfr_size the size of the ixfr files
#
define nsd::zone (
  Array[String]                  $masters                = [],
  Array[String]                  $provide_xfrs           = [],
  Array[String]                  $allow_notify_additions = [],
  Array[String]                  $send_notify_additions  = [],
  Optional[String]               $zonefile               = undef,
  Optional[Stdlib::Unixpath]     $zone_dir               = undef,
  Array[Nsd::Rrltype]            $rrl_whitelist          = [],
  Optional[Enum['on','off']]     $zonemd_verify          = undef,
  Optional[Nsd::Zonemd_generate] $zonemd_generate        = undef,
  Optional[Stdlib::Yes_no]       $allow_axfr_fallback    = undef,
  Optional[Stdlib::Yes_no]       $create_ixfr            = undef,
  Optional[Integer]              $ixfr_size              = undef,
) {
  include nsd
  $default_masters      = $nsd::default_masters
  $default_provide_xfrs = $nsd::default_provide_xfrs
  $imports              = $nsd::imports
  $_allow_axfr_fallback = pick_default($allow_axfr_fallback, $nsd::default_allow_axfr_fallback)
  $_create_ixfr         = pick_default($create_ixfr, $nsd::default_create_ixfr)
  $_ixfr_size           = pick_default($ixfr_size, $nsd::default_ixfr_size)
  if $zone_dir {
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $nsd::zone_subdir
  }
  if empty($rrl_whitelist) {
    $_rrl_whitelist = $nsd::rrl_whitelist
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

  concat::fragment { "nsd_zones_${name}":
    target  => $nsd::conf_file,
    content => template($nsd::zones_template),
    order   => 20;
  }
}
