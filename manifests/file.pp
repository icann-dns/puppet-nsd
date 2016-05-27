# Define: nsd::file
#
define nsd::file (
    $owner            = 'root',
    $group            = 'nsd',
    $mode             = '0640',
    $source           = undef,
    $content          = undef,
    $content_template = undef,
    $ensure           = 'present',
) {
  validate_string($owner)
  validate_string($group)
  validate_re($mode, '^\d+$')
  if $source {
    validate_string($source)
  }
  if $content and $content_template {
    fail('can\'t set $content and $content_template')
  } elsif $content {
    validate_string($content)
    $_content = $content
  } elsif $content_template {
    validate_absolute_path("/${content_template}")
    $_content = template($content_template)
  } else {
    $_content = undef
  }
  validate_string($ensure)
  $zone_subdir      = $::nsd::zone_subdir

  file { "${zone_subdir}/${title}":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $_content,
    require => Package[$::nsd::package_name],
    notify  => Service[$::nsd::service_name];
  }
}

