# Define: nsd::tsig
#
define nsd::tsig (
    $algo     = 'hmac-sha256',
    $data     = false,
    $template = 'nsd/etc/nsd/nsd.key.conf.erb',
) {
  validate_re($algo, ['^hmac-sha(1|224|256|384|512)$', '^hmac-md5$'])
  validate_string($data)
  validate_absolute_path("/${template}")

  concat::fragment{ "nsd_key_${name}":
    target  => $::nsd::conf_file,
    content => template($template),
    order   => 10;
  }
}

