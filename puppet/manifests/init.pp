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