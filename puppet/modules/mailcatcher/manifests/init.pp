class mailcatcher {

  include ::apt

  ::apt::ppa { 'ppa:brightbox/ruby-ng': }

  class { 'ruby::dev':
    require        => Apt::Ppa['ppa:brightbox/ruby-ng'],
  }

  package { 'libsqlite3-dev':
      ensure => present,
  }

  exec { 'install-mailcatcher':
      path => '/usr/bin',
      command => 'sudo gem install mailcatcher',
      require => [Class['ruby::dev'], Package['libsqlite3-dev']],
  }

  file { '/etc/init/mailcatcher.conf' :
      path => '/etc/init/mailcatcher.conf',
      source  => 'puppet:///modules/mailcatcher/service.conf',
      ensure => file,
      require => Exec['install-mailcatcher'],
  }

   # exec { 'mailcatcher-php' :
   #     path => '/usr/bin',
   #     command => 'echo "sendmail_path = /usr/bin/env $(which catchmail) -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini && sudo php5enmod mailcatcher',
   #     require => Exec['install-mailcatcher'],
   #     notify  => Service['apache2'],
   # }

}
