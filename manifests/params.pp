
class puppetdb_rundeck::params {
  $with_sinatra         = true
  $approot              = '/etc/puppetdb_rundeck'
  $servername           = $::fqdn
  $port                 = '8888'
  $puppetdb_host        = 'localhost'
  $puppetdb_port        = '8080'
  $default_mods         = true
  $default_vhost        = true
  $default_confd_files  = true

  case $::osfamily {
    'redhat': {
      $owner = 'apache'
      $group = 'apache'
    }
    'debian': {
      $owner = 'www-data'
      $group = 'www-data'
    }
  }

}
