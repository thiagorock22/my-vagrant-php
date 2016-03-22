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
  -> Class['mailcatcher']
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
  override         => 'All',
}

apache::vhost { 'subdomain.devlocal':
  vhost_name       => '*.devlocal',
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

class { 'mailcatcher': }

class { 'git': }

exec { 'mailcatcher-php' :
  command => '/bin/echo "sendmail_path = /usr/bin/env $(which catchmail) -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini && sudo php5enmod mailcatcher'
}

swap_file::files { 'default':
    ensure   => present,
}

apache::custom_config { 'adminer.php':
    source => 'puppet:///modules/adminer/adminer.conf'
}

file { 'create_folder_adminer':
    path => '/usr/share/adminer/',
    ensure => directory,
}

exec {'retrieve_adminer':
    command => "/usr/bin/wget -q http://www.adminer.org/latest-mysql-en.php -O /usr/share/adminer/adminer.php",
    creates => "/usr/share/adminer/adminer.php",
    require => File["create_folder_adminer"],
}
