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

include php

class { 'php::cli': }

class { ['php::extension::curl','php::extension::gd', 'php::extension::mcrypt','php::extension::mysql','php::extension::opcache'] : }

class { ['php::composer', 'php::composer::auto_update']:
  destination => '/usr/bin/composer'
}

class { 'apache':
  default_vhost => false,
  mpm_module => 'prefork',
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
  override         => 'All',
  serveraliases    => ['*.devlocal',],
}

class { 'apache::mod::rewrite': }

class { 'apache::mod::php': }

class { 'mysql::server':
  root_password => '123456',
}