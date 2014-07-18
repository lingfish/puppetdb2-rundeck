
class puppetdb_rundeck::params {
  $with_sinatra     = true
  $approot         = '/etc/puppetdb_rundeck/'
  $servername       = $::fqdn
  $port             = '8888'
  $puppetdb_host    = 'localhost'
  $puppetdb_port    = '8080'


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
