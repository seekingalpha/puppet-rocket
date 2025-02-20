# == Class: rocketchat
#
# Main class for Rocket.Chat installation and configuration
#
# === Parameters

# === Authors
#
# Karol Kozakowski <cosaquee@gmail.com>
#
# === Copyright
#
# Copyright 2017 Karol Kozakowski
#
class rocketchat (
  $port               = $rocketchat::params::port,
  $instance_count     = $rocketchat::params::instance_count,
  $max_old_space_size = $rocketchat::params::max_old_space_size,
  $root_url           = $rocketchat::params::root_url,
  $download_path      = $rocketchat::params::download_path,
  $destination        = $rocketchat::params::destination,
  $package_ensure     = $rocketchat::params::package_ensure,
  $package_source     = $rocketchat::params::package_source,
  $mongo_host         = $rocketchat::params::mongo_host,
  $database_name      = $rocketchat::params::database_name,
  $mongo_port         = $rocketchat::params::mongo_port,
  $mongo_replset      = $rocketchat::params::mongo_replset,
  $mongo_native_oplog = $rocketchat::params::mongo_native_oplog,
  $authsource         = $rocketchat::params::authsource,
  $nodejs_version     = $rocketchat::params::nodejs_version,
  $nodejs_source      = $rocketchat::params::nodejs_source,
  $nodejs_deps        = $rocketchat::params::nodejs_deps,
  $manage_repos       = $rocketchat::params::manage_repos,
  $mongo_version      = $rocketchat::params::mongo_version,
  $verbose            = $rocketchat::params::verbose,
  $speakeasy_http_header_name = undef,
  $speakeasy_http_header_value = undef,
  $slack_token        = undef,
) inherits rocketchat::params {

  class { 'rocketchat::packages':
    nodejs_version => $nodejs_version,
    nodejs_source => $nodejs_source,
    nodejs_deps    => $nodejs_deps
  }

  if ($mongo_host == 'localhost') {
    class { 'rocketchat::database':
      port         => $mongo_port,
      verbose      => $verbose,
      manage_repos => $manage_repos,
      version      => $mongo_version,
      require      => Class['rocketchat::packages'],
      before       => Class['rocketchat::install'],
    }
  }

  class { 'rocketchat::install':
    download_path  => $download_path,
    destination    => $destination,
    package_ensure => $package_ensure,
    package_source => $package_source
  }

  class { 'rocketchat::service':
    port               => $port,
    instance_count     => $instance_count,
    max_old_space_size => $max_old_space_size,
    mongo_host         => $mongo_host,
    mongo_port         => $mongo_port,
    mongo_replset      => $mongo_replset,
    mongo_native_oplog => $mongo_native_oplog,
    authsource         => $authsource,
    database_name      => $database_name,
    root_url           => $root_url,
    destination        => $destination,
    speakeasy_http_header_name  => $speakeasy_http_header_name,
    speakeasy_http_header_value => $speakeasy_http_header_value,
    slack_token        => $slack_token,
    require            => Class['rocketchat::install']
  }
}
