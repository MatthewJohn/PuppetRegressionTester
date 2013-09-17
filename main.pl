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

our $main_logger = PRT::Logger->new();
$main_logger->log('Starting logging');

my $virtual_machine = PRT::VirtualMachine->new(vm_type => $PRT::Config::VAGRANT_BOXES{'1'});
$virtual_machine->execute();
