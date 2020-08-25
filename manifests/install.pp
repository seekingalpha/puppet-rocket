class rocketchat::install(
  $download_path,
  $destination,
  $package_ensure,
  $package_source,
  $bundle_url,
) {
  include wget

  $file_path = "${download_path}/rocket.tgz"

  # The API for generating the URL to fetch has gone through some evolution.
  # To ease the transition, support the different formats:
  # - v1: specify just $package_ensure (an oddly-named release identifier)
  # - v2: specify $package_source (a base URL) and $package_ensure
  # - v3: specify $bundle_url (the full, final URL)
  $source = $bundle_url ? {
    default => $bundle_url,
    undef   => $package_source ? {
                 default => "${package_source}/rocket.chat-${package_ensure}.tgz",
                 undef   => "https://rocket.chat/releases/${package_ensure}/download",
               },
  }

  wget::fetch { 'Download stable Rocket.Chat package':
    source      => $source,
    destination => $file_path,
    verbose     => false,
    before      => Archive[$file_path],
    unless      => "test -d ${destination}/bundle/server",
  }

  file { $destination:
    ensure => directory,
  }

  archive { $file_path:
    path         => $file_path,
    extract      => true,
    extract_path => $destination,
    require      => File[$destination],
    creates      => "${destination}/bundle/server",
  }

  exec { 'npm install':
    cwd     => "${destination}/bundle/programs/server/",
    creates => "${destination}/bundle/programs/server/node_modules/",
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin',
    require => [Archive[$file_path], Class['rocketchat::packages']],
  }
}
