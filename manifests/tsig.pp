# Define: nsd::tsig
#
define nsd::tsig (
    String    $data,
    Nsd::Algo $algo     = 'hmac-sha256',
    String    $template = 'nsd/etc/nsd/nsd.key.conf.erb',
    String    $key_name = undef,
) {
  include ::nsd
  concat::fragment{ "nsd_key_${name}":
    target  => $::nsd::conf_file,
    content => template($template),
    order   => 10;
  }
}

