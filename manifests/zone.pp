#== Class: nsd
#
define nsd::zone (
  $masters          = [],
  $notify_addresses = [],
  $allow_notify     = [],
  $provide_xfr      = [],
  $zones            = [],
  $zonefile         = undef,
  $zone_dir         = undef,
  $rrl_whitelist    = [],
) {
  validate_array($masters)
  validate_array($notify_addresses)
  validate_array($allow_notify)
  validate_array($provide_xfr)
  validate_array($zones)
  if $zonefile {
    validate_string($zonefile)
  }
  if $zone_dir {
    validate_absolute_path($zone_dir)
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $::nsd::zone_subdir
  }
  
  if empty($rrl_whitelist) {
    $_rrl_whitelist = $::nsd::rrl_whitelist
  } else {
    $_rrl_whitelist = $rrl_whitelist
  }
  validate_array($_rrl_whitelist)

  concat::fragment{ "nsd_zones_${name}":
    target  => $::nsd::nsd_conf_file,
    content => template($::nsd::zones_template),
    order   => 20;
  }
}
