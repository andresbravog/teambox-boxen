require boxen::environment
require homebrew
require gcc

# include the osx module referenced in my Puppetfile with the line
# github "osx"
# include osx::global::disable_key_press_and_hold
# include osx::global::enable_keyboard_control_access
# include osx::global::expand_print_dialog
# include osx::global::expand_save_dialog
# include osx::disable_app_quarantine
# include osx::no_network_dsstores
# include osx::global::key_repeat_delay
# include osx::global::key_repeat_rate
# include osx::universal_access::cursor_size

# include the sublime_text_2 module referenced in my Puppetfile with the line
# github "sublime_text_2"
# include sublime_text_2
# sublime_text_2::package { 'Emmet':
#   source => 'sergeche/emmet-sublime'
# }

# include pow

include imagemagick
# include memcached
include mysql

# include iterm2::stable
# include fish

# include github_for_mac

# include sequel_pro

# class { 'osx::global::key_repeat_delay':
#   delay => 10
# }

# include vim
# vim::bundle { [
#   'scrooloose/syntastic',
#   'sjl/gundo.vim'
# ]: }

# # Example of how you can manage your .vimrc
# file { "${vim::vimrc}":
#   target  => "/Users/${::boxen_user}/.dotfiles/.vimrc",
#   require => Repository["/Users/${::boxen_user}/.dotfiles"]
# }

# # Or, simply,
# file { "${vim::vimrc}": ensure => exists }


Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $luser,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::luser}"
  ]
}

File {
  group => 'staff',
  owner => $luser
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => Class['git'],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  include nodejs::v0_4
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  include ruby::1_8_7
  include ruby::1_9_2
  include ruby::1_9_3
  include ruby::2_0_0

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
