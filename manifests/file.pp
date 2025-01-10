# @summary define for creating nsd zone files
# @param ensure the ensure value for the file
# @param owner the owner of the file
# @param group the group of the file
# @param mode the mode of the file
# @param source the source of the file
# @param content the content of the file
# @param content_template the template to use for the content
#
define nsd::file (
  String                       $ensure           = 'present',
  String                       $owner            = 'root',
  String                       $group            = 'nsd',
  Stdlib::Filemode             $mode             = '0640',
  Optional[Stdlib::Filesource] $source           = undef,
  Optional[String]             $content          = undef,
  Optional[String] $content_template = undef,
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

  file { "${nsd::zone_subdir}/${title}":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $_content,
    require => Package[$nsd::package_name],
    notify  => Service[$nsd::service_name];
  }
}
