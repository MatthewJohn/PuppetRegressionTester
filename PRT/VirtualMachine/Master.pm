package PRT::VirtualMachine::Master;
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

  unless ($self->{'vm_type'})
  {
  	$self->{'vm_type'} = $PRT::Config::VAGRANT_BOXES{'1'};
  }

  return $self;
}

sub configure
{
  my ($self) = @_;

  # Create the machine
  $self->createBaseDirectory();
  $self->createVirtualMachine();

  # Configure the machine
  $self->createConfigurationFiles('master');
  $self->startMachine();
  $self->configureVirtualMachine();
}

1;