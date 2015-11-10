exec { 'apt-get update':
    path => '/usr/bin',
}

package { 'vim':
    ensure => present,
}

package { 'htop':
    ensure => present,
}

class { 'locales':
  default_locale => 'pt_BR.UTF-8',
  locales        => ['pt_BR.UTF-8 UTF-8', 'en_US.UTF-8 UTF-8']
}

Exec['apt-get update']
  -> Package['php5-common']
  -> Package['php5-dev']
  -> Package['php5-cli']
  -> Php::Extension <| |>
  -> Class['mymailcatcher']
  -> Exec['mailcatcher-php']

class { [ 'php::dev', 'php::cli' ]: }

class { ['php::extension::curl','php::extension::gd','php::extension::mcrypt','php::extension::mysql','php::extension::opcache'] : }

class { ['php::composer', 'php::composer::auto_update']:
  destination => '/usr/bin/composer'
}

class { 'apache':
  default_vhost => false,
  mpm_module => 'prefork',
  user => 'vagrant',
  group => 'vagrant',
}

apache::vhost { 'devlocal':
  port    => '80',
  docroot => '/var/www',
  docroot_owner => 'vagrant',
  docroot_group => 'vagrant',
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

# include php
class { 'mymailcatcher': }

exec { 'mailcatcher-php' :
  command => '/bin/echo "sendmail_path = /usr/bin/env $(which catchmail) -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini && sudo php5enmod mailcatcher'
}