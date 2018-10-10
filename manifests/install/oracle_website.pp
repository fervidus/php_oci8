# == Class php_oci8::install:oracle_website
#
# Author: Paul Talbot, Autostructure
#
# ===============================================
#
# ===============================================
#
# @summary
#   Called by php_oci8::install class to install from default source
#

class php_oci8::install::oracle_website {

  # archive module is used to download packages
  include ::archive

  $temp_location = $::facts['env_temp_variable']
  file { $temp_location:
    ensure  => 'directory',
  }

  $oracle_url_proxy_server = $::php_oci8::oracle_url_proxy_server
  $oracle_url_proxy_type = $::php_oci8::oracle_url_proxy_type

  # determine package type
  case $facts['kernel'] {
    'Linux' : {
      case $facts['os']['family'] {
        'RedHat', 'Amazon' : {
          $package_type = 'rpm'
        }
        default : {
          fail ("Unsupported OS family ${$facts['os']['family']}.") }
      }
    }
    default : {
      fail ( "Unsupported platform ${$facts['kernel']}." ) }
  }

  # architecture mapping
  case $facts['os']['architecture'] {
    'i386' : {
      $arch = 'i386'
      $basic_name = 'basiclite'
      $devel_name = 'devellite'
    }
    'x86_64' : {
      $arch = 'x86_64'
      $basic_name = 'basic'
      $devel_name = 'devel'
    }
    'amd64' : {
      $arch = 'x86_64'
      $basic_name = 'basic'
      $devel_name = 'devel'
    }
    default : {
      fail ("Unsupported architecture ${$facts['os']['architecture']}")
    }
  }

  # following are based on these examples:
  # http://download.oracle.com/otn/linux/instantclient/183000/oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm
  # http://download.oracle.com/otn/linux/instantclient/183000/oracle-instantclient18.3-basiclite-18.3.0.0.0-1.i386.rpm
  #
  case $package_type {
    'rpm' : {
      $package_name_basic = "${::php_oci8::instantclient_product_name}${::php_oci8::instantclient_major}.${::php_oci8::instantclient_minor}-${basic_name}-${::php_oci8::instantclient_major}.${::php_oci8::instantclient_minor}.${::php_oci8::instantclient_patch_a}.${::php_oci8::instantclient_patch_b}.${::php_oci8::instantclient_patch_c}-1.${arch}.${package_type}"
      $package_name_devel = "${::php_oci8::instantclient_product_name}${::php_oci8::instantclient_major}.${::php_oci8::instantclient_minor}-${devel_name}-${::php_oci8::instantclient_major}.${::php_oci8::instantclient_minor}.${::php_oci8::instantclient_patch_a}.${::php_oci8::instantclient_patch_b}.${::php_oci8::instantclient_patch_c}-1.${arch}.${package_type}"
    }
    default : {
      fail ("Unknown package type ${package_type}.")
    }
  }

  $source_basic = "${::php_oci8::oracle_url}/${::php_oci8::instantclient_major}${::php_oci8::instantclient_minor}${::php_oci8::instantclient_patch_a}${::php_oci8::instantclient_patch_b}${::php_oci8::instantclient_patch_c}/${package_name_basic}"
  $source_devel = "${::php_oci8::oracle_url}/${::php_oci8::instantclient_major}${::php_oci8::instantclient_minor}${::php_oci8::instantclient_patch_a}${::php_oci8::instantclient_patch_b}${::php_oci8::instantclient_patch_c}/${package_name_devel}"

  # full path(s) to the installers
  $destination_basic = "${temp_location}/${package_name_basic}"
  $destination_devel = "${temp_location}/${package_name_devel}"
  #notice ("Destination for basic is ${destination_basic}.")
  #notice ("Destination for devel is ${destination_devel}.")

  archive { $destination_basic:
    ensure       => 'present',
    source       => $source_basic,
    cookie       => 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie',
    extract_path => $temp_location,
    cleanup      => false,
    creates      => $destination_basic,
    proxy_server => $oracle_url_proxy_server,
    proxy_type   => $oracle_url_proxy_type,
  }
  archive { $destination_devel:
    ensure       => 'present',
    source       => $source_devel,
    cookie       => 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie',
    extract_path => $temp_location,
    cleanup      => false,
    creates      => $destination_devel,
    proxy_server => $oracle_url_proxy_server,
    proxy_type   => $oracle_url_proxy_type,
  }

  package { $destination_basic:
    ensure          => 'installed',
    provider        => 'rpm',
    source          => $destination_basic,
    install_options => '--force',
    require         => Archive[$destination_basic],
  }

  package { $destination_devel:
    ensure          => 'installed',
    provider        => 'rpm',
    source          => $destination_devel,
    install_options => '--force',
    require         => Archive[$destination_devel],
  }

}