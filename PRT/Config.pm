package PRT::Config;

use strict;
use warnings;

use Cwd 'abs_path';
use FindBin;

# Setup system paths
our $VAGRANT_PATH = '/usr/bin/vagrant';
our $APP_BASE_DIR = abs_path($0);
$APP_BASE_DIR = $FindBin::Bin;
our $SCRIPT_PATH = $APP_BASE_DIR . '/scripts';
our $LOG_BASE_DIR = $APP_BASE_DIR . '/logs';
our $TEST_BASE_DIR = $APP_BASE_DIR . '/tests';
our $PUPPET_BASE_DIR = $APP_BASE_DIR . '/puppet';

# Vagrant VM shared path
our $VM_SHARE_PATH = '/vagrant';

# Debug logging
our $DEBUG = 0;

# Configure vagrant images
our %VAGRANT_BOXES =
(
  1 =>
  {
    'dist' => 'ubuntu',
    'version' => '12.04',
    'codename' => 'precise',
    'arch' => '64',
    'box_name' => 'precise64'
  }
);

1;
