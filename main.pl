#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/";
use PRT::Config;
use PRT::Test;
use PRT::VirtualMachine;

use Data::Dumper;

my $virtual_machine = PRT::VirtualMachine->new(vm_type => $PRT::Config::VAGRANT_BOXES{'1'});
$virtual_machine->runTest();
