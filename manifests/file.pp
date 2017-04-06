# Define: nsd::file
#
define nsd::file (
    String                       $owner            = 'root',
    String                       $group            = 'nsd',
    Pattern[/^\d+$/]             $mode             = '0640',
    Optional[Tea::Puppetsource]  $source           = undef,
    Optional[String]             $content          = undef,
    Optional[Tea::Puppetcontent] $content_template = undef,
    String                       $ensure           = 'present',
) {
  if $content and $content_template {
    fail('can\'t set $content and $content_template')
  } elsif $content {
    $_content = $content
  } elsif $content_template {
    $_content = template($content_template)
  } else {
    $_content = undef
  }

  file { "${::nsd::zone_subdir}/${title}":
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

