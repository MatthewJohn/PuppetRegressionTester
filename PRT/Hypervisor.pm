package PRT::Hypervisor;

use strict;
use warnings;

use PRT::Logger;

sub new
{
  my ($class, %args) = @_;

  my $self =  bless
  (
    {
      %args
    },
    $class
  );

  # Ensure that virsh is installed and check 
  (my $exit_code, $self->{'vrish_bin'}) = PRT::runCommand('which virsh');
  chomp($self->{'vrish_bin'});
  if ($exit_code)
  {
  	$self->{'logger'}->error('Could not find vrish bin');
  }

  $self->{'net'} = [];
  $self->{'pool'} = [];
  $self->{'dom'} = [];

  return $self;
}

1;