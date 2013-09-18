#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use POSIX qw(strftime);

use lib "$FindBin::Bin/";
use PRT::Config;
use PRT::Logger;
use PRT::Test;
use PRT::VirtualMachine;
use Data::Dumper;

my $test1 = PRT::Test->new(test_id => 1);

my $virtual_machine = PRT::VirtualMachine->new
(
  vm_type => $PRT::Config::VAGRANT_BOXES{'1'},
  test => $test1
);
$virtual_machine->execute();

$PRT::Logger::main_logger->log('Completed all tests');
