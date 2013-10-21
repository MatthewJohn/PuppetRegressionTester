package PRT::VirtualMachine::TestMachine;
use parent 'PRT::VirtualMachine';

use strict;
use warnings;

use File::Temp;
use File::Copy;
use Text::Template;
use File::Copy::Recursive;

use PRT::VirtualMachine;

sub new
{
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);

  return $self;
}

sub runTestMachine
{
  my ($self, $master_server_object) = @_;

  # Set the object for the master machine
  $self->{'master'} = $master_server_object;

  # Creat the machine
  $self->createBaseDirectory();
  $self->createVirtualMachine();

  # Configure the machine
  $self->createConfigurationFiles('client');
  $self->startMachine();
  $self->configureVirtualMachine();

  # Run main tests
  $self->runTest();

  # Destroy
  $self->stopAndDestroy();
}

sub runTest
{
  my ($self) = @_;

  $self->{'logger'}->log('Would run a test here');
}

sub connectToMaster
{
  my ($self)
}

1;