#== Define: nsd::pattern
# see pattern specification for NSD: https://www.nlnetlabs.nl/documentation/nsd/nsd.conf/
define nsd::pattern (
  Optional[String[1]]                          $zonefile            = undef,
  Array[Nsd::Server]                           $allow_notifies      = [],
  Array[Nsd::Server]                           $request_xfrs        = [],
  Optional[Boolean]                            $allow_axfr_fallback = undef,
  Optional[Integer]                            $size_limit_xfr      = undef,
  Array[Nsd::Server]                           $notifies            = [],
  Optional[Integer]                            $notify_retry        = undef,
  Array[Nsd::Server]                           $provide_xfrs        = [],
  ## it is possible to add this option multiple times, however, only the last outgoing-interface of a protocol is used, therefore, no array here
  Optional[Tea::Ipv4]                          $outgoing_interface4 = undef,
  ## it is possible to add this option multiple times, however, only the last outgoing-interface of a protocol is used, therefore, no array here
  Optional[Tea::Ipv6]                          $outgoing_interface6 = undef,
  Optional[Integer]                            $max_refresh_time    = undef,
  Optional[Integer]                            $min_refresh_time    = undef,
  Optional[Integer]                            $max_retry_time      = undef,
  Optional[Integer]                            $min_retry_time      = undef,
  Optional[String[1]]                          $zonestats           = undef,
  Array[String[1]]                             $include_patterns    = [],
  Optional[Boolean]                            $multi_master_check  = undef,
  String[1]                                    $order               = '15', ## allow overriding the order
) {
  include ::nsd

  $include_patterns.each |String $include_pattern| {
    unless defined(Nsd::Pattern[$include_pattern]) {
      fail("${name}: Nsd::Pattern['${include_pattern}'] does not exist")
    }
    if $order < Nsd::Pattern[$include_pattern]['order'] {
      fail("${name}: Nsd::Pattern['${include_pattern}'] must be in conf file prior to '${name}'")
    }
  }

  $servers_instance = {
    'allow-notify' => $allow_notifies,
    'request-xfr'  => $request_xfrs,
    'notify'       => $notifies,
    'provide-xfr'  => $provide_xfrs,
  }
  $servers_instance.each |String $key, Array $servers| {
    $servers.each |Nsd::Server $server| {
      unless $server['address4'] or $server['address6'] {
        fail("${name}: '${key}' has server definition without address")
      }
      if $server['tsig_name'] and !defined(Nsd::Tsig[$server['tsig_name']]) {
        fail("${name}: '${key}' has undefined tsig_name")
      }
    }
  }

  concat::fragment { "nsd_pattern_${name}":
    target  => $::nsd::conf_file,
    content => template($::nsd::pattern_template),
    order   => $order;
  }
}
