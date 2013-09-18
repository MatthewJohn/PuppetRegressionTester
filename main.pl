#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use POSIX qw(strftime);

use lib "$FindBin::Bin/";
use PRT::Config;
use PRT::Logger;
use PRT;
use PRT::Test;
use PRT::VirtualMachine;
use Data::Dumper;

# Setup puppet master
our $puppet_master = PRT::VirtualMachine->new
(
  vm_type => $PRT::Config::VAGRANT_BOXES{'1'},
  logger => $PRT::Logger::main_logger
);
$puppet_master->setupMaster();

# Setup and run tests
my $test1 = PRT::Test->new(test_id => 1);

my $virtual_machine = $test1->createVM
(
  $PRT::Config::VAGRANT_BOXES{'1'}
);
$virtual_machine->runTestMachine();

# Stopping puppet master
$puppet_master->stopAndDestroy();
$PRT::Logger::main_logger->log('Completed all tests');
