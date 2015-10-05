exec { 'apt-get update':
    path => '/usr/bin',
}

package { 'vim':
    ensure => present,
}

package { 'htop':
    ensure => present,
}

package { 'language-pack-pt':
    ensure => present,
}

class { 'apache':
  default_vhost => false,
}

apache::vhost { 'devlocal':
  port    => '80',
  docroot => '/var/www',
  docroot_owner => 'www-data',
  docroot_group => 'www-data',
}

apache::vhost { 'subdomain.devlocal':
  vhost_name       => '*',
  port             => '80',
  virtual_docroot  => '/var/www/%-2+',
  docroot          => '/var/www',
  serveraliases    => ['*.devlocal',],
}

class { 'apache::mod::rewrite': }

class { 'mysql::server':
  root_password => '123456',
}