Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { 'apt-get update':
    path => '/usr/bin',
}

class development {

  $devPackages = [ "curl", "git", "nodejs", "npm", "openjdk-7-jdk" ]

  package { $devPackages:
    ensure => present,
  }

  exec { 'install less using npm':
    command => 'npm install less -g',
    require => Package["npm"],
  }
}

class systemandtools {

  package { 'vim':
      ensure => present,
  }

  package { 'htop':
      ensure => present,
  }


  package { 'build-essential':
    ensure => present,
    require => Exec['apt-get update'],
  }

  class { 'locales':
    default_locale => 'pt_BR.UTF-8',
    locales        => ['pt_BR.UTF-8 UTF-8', 'en_US.UTF-8 UTF-8']
  }

  swap_file::files { 'default':
    ensure   => present,
  }
}

class phpinstall {

  include php::dev
  include php::cli

  class { ['php::composer', 'php::composer::auto_update']:
    destination => '/usr/bin/composer'
  }

  $extensions = ['php::extension::curl','php::extension::gd','php::extension::mcrypt','php::extension::mysql','php::extension::opcache']

  include $extensions

}

class apacheinstall {

  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
    user          => 'vagrant',
    group         => 'vagrant',
    docroot       => '/var/www/html',
  }

  apache::vhost { 'local':
    port           => '80',
    docroot        => '/var/www/html',
    docroot_owner  => 'vagrant',
    docroot_group  => 'vagrant',
    override       => 'All',
  }

  apache::vhost { 'devlocal':
    port           => '80',
    docroot        => '/usr/share/devlocal/public',
    docroot_owner  => 'vagrant',
    docroot_group  => 'vagrant',
    override       => 'All',
  }

  apache::vhost { 'subdomain.devlocal':
    vhost_name       => '*.devlocal',
    port             => '80',
    virtual_docroot  => '/var/www/html/%-2+',
    docroot          => '/var/www/html',
    override         => 'All',
    serveraliases    => ['*.devlocal',],
  }

  include [ 'apache::mod::rewrite', 'apache::mod::php' ]
}

class mysqlinstall {

  class { 'mysql::server':
    root_password => '123456',
  }

}

class adminerinstall {

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

}

class installmailcatcher {

  include mailcatcher

  exec { 'mailcatcher-php' :
    command => '/bin/echo "sendmail_path = /usr/bin/env $(which catchmail) -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini && sudo php5enmod mailcatcher'
  }
}

include systemandtools
include development
include phpinstall
include apacheinstall
include mysqlinstall
include adminerinstall
include installmailcatcher

Exec["apt-get update"] -> Package <| |>


# class { 'mailcatcher': }

# exec { 'mailcatcher-php' :
#   command => '/bin/echo "sendmail_path = /usr/bin/env $(which catchmail) -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini && sudo php5enmod mailcatcher'
# }