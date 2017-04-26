#== Define: nsd::remote
#
define nsd::remote (
  Optional[Variant[Tea::Ipv4, Tea::Ipv4_cidr]] $address4  = undef,
  Optional[Variant[Tea::Ipv6, Tea::Ipv6_cidr]] $address6  = undef,
  Optional[String]                             $tsig      = undef,
  Optional[String]                             $tsig_name = undef,
  Tea::Port                                    $port      = 53,
) {
  include ::nsd
  if ! $address4 and ! $address6 {
    fail("${name} must specify either address4 or address6")
  }
  if $tsig {
    if ! defined(Nsd::Tsig[$tsig]) {
      fail("${name}: Nsd::Tsig['${tsig}'] does not exist")
    }
    if ! $tsig_name {
      fail("${name}: you must define tsig_name when you deinfe tsig")
    } else {
      $_tsig_name = $tsig_name
    }
  } elsif $tsig_name and $tsig_name != '' {
    if defined(Nsd::Tsig[$tsig_name]) or $tsig_name == 'NOKEY' {
      $_tsig_name = $tsig_name
    } else {
      fail("${name}: Nsd::Tsig['${tsig_name}'] does not exist")
    }
  } else {
    $_tsig_name = $::nsd::default_tsig_name
  }
  concat::fragment{ "nsd_pattern_${name}":
    target  => $::nsd::conf_file,
    content => template($::nsd::pattern_template),
    order   => '15';
  }
  #if $::nsd::manage_nagios and $::nsd::enable {
  #  nsd::zone::nagios {$zones:
  #    masters => $masters,
  #    slaves  => $provide_xfr,
  #  }
  #}
}
