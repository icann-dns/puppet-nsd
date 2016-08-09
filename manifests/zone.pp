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
  $tsig_name        = undef,
  $slave_addresses  = {},
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
  if $tsig_name {
    validate_string($tsig_name)
    if defined(Nsd::Tsig[$tsig_name]) {
      $_tsig_name = $tsig_name
    } else {
      fail("Nsd::Tsig['${tsig_name}'] does not exist")
    }
  } elsif has_key($::nsd::tsig, 'name') {
    $_tsig_name = $::nsd::tsig['name']
  }
  if empty($slave_addresses) {
    $_slave_addresses = $::nsd::slave_addresses
  } else {
    validate_hash($slave_addresses)
    $_slave_addresses = $slave_addresses
  }

  concat::fragment{ "nsd_zones_${name}":
    target  => $::nsd::conf_file,
    content => template($::nsd::zones_template),
    order   => 20;
  }
  if $::nsd::manage_nagios {
    nsd::zone::nagios {$zones:
      masters => $masters,
      slaves  => $provide_xfr,
    }
  }
}
