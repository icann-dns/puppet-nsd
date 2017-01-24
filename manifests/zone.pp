#== Class: nsd
#
define nsd::zone (
  Array                       $masters          = [],
  Array                       $notify_addresses = [],
  Array                       $allow_notify     = [],
  Array                       $provide_xfr      = [],
  Array                       $zones            = [],
  Optional[String]            $zonefile         = undef,
  Optional[Tea::Absolutepath] $zone_dir         = undef,
  Array                       $rrl_whitelist    = [],
  Optional[String]            $tsig_name        = undef,
  Hash                        $slave_addresses  = {},
) {
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
  if $tsig_name {
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
