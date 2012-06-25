class pureftpd::config {
    file { "${pureftpd::params::config_dir}conf":
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        owner   => root,
        group   => root,
        source  => $source ? {
            undef      => "puppet:///modules/${module_name}/${pureftpd::params::config_source}/conf",
            default => $pureftpd::config_source,
        },
        require => Class['pureftpd::install'],
        notify  => Class['pureftpd::service'],
    }

    file { $pureftpd::params::config_default_file:
        ensure  => present,
        owner   => root,
        group   => root,
        content => template("${module_name}/default_config.erb"),
        require => Class['pureftpd::install'],
        notify  => Class['pureftpd::service'],
    }
    
    if $mysql_config {
      $pureftpd_mysql_user = hiera('pureftpd_mysql_user', 'root')
      $pureftpd_mysql_password = hiera('pureftpd_mysql_password', 'rootpw')
      $pureftpd_mysql_database = hiera('pureftpd_mysql_database', 'ftpd')
      $pureftpd_crypt_method = hiera('pureftpd_crypt_method', 'cleartext')
      file {
        "${pureftpd::params::config_dir}db/mysql.conf":
          content => template("${module_name}/mysql.conf.erb"),
          require => Class['pureftpd::install'],
          notify  => Class['pureftpd::service'];
        "${pureftpd::params::config_dir}conf/MySQLConfigFile":
          content => "${pureftpd::params::config_dir}db/mysql.conf",
          require => Class['pureftpd::install'],
          notify  => Class['pureftpd::service'];
      }
    }
}
