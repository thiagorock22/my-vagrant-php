class mailcatcher {

    package { 'libsqlite3-dev':
        ensure => present,
    }

    package { 'ruby1.9.1-dev':
        ensure => present,
    }

    exec { 'install-mailcatcher':
        path => '/usr/bin',
        command => 'sudo gem install mailcatcher',
        require => Package['libsqlite3-dev','ruby1.9.1-dev'],
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
