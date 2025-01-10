# @summary define for creating nsd zone files
# @param data the data for the tsig key
# @param algo the algorithm to use
# @param template the template to use for the key
# @param key_name the name of the key
#
define nsd::tsig (
    String           $data,
    Nsd::Algo        $algo     = 'hmac-sha256',
    String           $template = 'nsd/etc/nsd/nsd.key.conf.erb',
    Optional[String] $key_name = undef,
) {
  include nsd
  concat::fragment{ "nsd_key_${name}":
    target  => $::nsd::conf_file,
    content => template($template),
    order   => 10;
  }
}

