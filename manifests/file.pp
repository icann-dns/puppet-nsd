# Define: nsd::file
#
define nsd::file (
    $owner   = 'root',
    $group   = 'nsd',
    $mode    = '0640',
    $source  = undef,
    $content = undef,
    $ensure  = 'present',
) {
  validate_string($owner)
  validate_string($group)
  validate_re($mode, '^\d+$')
  if $source {
    validate_string($source)
  }
  if $content {
    validate_string($content)
  }
  validate_string($ensure)
  $zone_subdir      = $::nsd::zone_subdir

  file { "${zone_subdir}/${title}":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $content,
    require => Package[$::nsd::nsd_package_name],
    notify  => Service[$::nsd::nsd_service_name];
  }
}

