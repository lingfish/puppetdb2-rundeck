class puppetdb_rundeck (
  $with_sinatra         = $puppetdb_rundeck::params::with_sinatra,
  $approot              = $puppetdb_rundeck::params::approot,
  $servername           = $puppetdb_rundeck::params::servername,
  $port                 = $puppetdb_rundeck::params::port,
  $puppetdb_port        = $puppetdb_rundeck::params::puppetdb_port,
  $puppetdb_host        = $puppetdb_rundeck::params::puppetdb_host,
  $owner                = $puppetdb_rundeck::params::owner,
  $group                = $puppetdb_rundeck::params::group,
  $default_mods         = $puppetdb_rundeck::params::default_mods,
  $default_vhost        = $puppetdb_rundeck::params::default_vhost,
  $default_confd_files  = $puppetdb_rundeck::params::default_confd_files,
) inherits puppetdb_rundeck::params {


  class { 'apache':
    default_mods        => $default_mods,
    default_vhost       => $default_vhost,
    default_confd_files => $default_confd_files,
  }

  class { 'apache::mod::passenger':
    before => Service['httpd'],
  }

  if $with_sinatra == true {
    if (!defined(Package['sinatra'])) {
      package { 'sinatra':
        ensure   => installed,
        provider => 'gem',
        notify   => Service['httpd'],
      }
    }
  }

  File {
    owner => $owner,
    group => $group,
  }

  file { [
    $approot,
    "${approot}/rack",
    "${approot}/rack/public",
    "${approot}/rack/tmp"
    ]:
      ensure => directory,
  }

  file { 
    "${approot}/rack/config.ru":
      ensure  => file,
      content => template('puppetdb_rundeck/config.ru.erb');

    "${approot}/rack/puppetdb-rundeck.rb":
      ensure  => file,
      content => template('puppetdb_rundeck/puppetdb-rundeck.rb.erb');
  }

  apache::vhost { 'rundeck-puppet':
    port            => $port,
    docroot         => "${approot}/rack/public",
    servername      => $servername,
    serveradmin     => 'root',
    rack_base_uris  => '/',
    priority        => '50',
    directories     => [
      {
        path            => "${approot}/rack/public",
        options         => 'Indexes Multiviews',
        allow_override  => 'None',
        order           => 'allow,deny',
        allow           => 'from all'
      },
      {
        path            => "${approot}/rack",
        options         => 'None',
        allow_override  => 'None',
        order           => 'allow,deny',
        allow_from      => 'all',
      }
    ],
    before          => Service['httpd'],
    require         => File["${approot}/rack/config.ru","${approot}/rack/puppetdb-rundeck.rb"],
  }
}




