package PRT::Test;

use strict;
use warnings;

#use Exporter qw(import);
#our @EXPORT_OK = qw();

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
  if (!$self->{'test_id'})
  {
    $PRT::Logger::main_logger->log("Error: test_id not defined\n");
    die();
  }
  $self->{'base_directory'} = $PRT::Config::TEST_BASE_DIR . '/' . $self->{'test_id'};
  $self->checkExists();

  $self->{'logger'} = PRT::Logger->new(name => 'test_' . $self->{'test_id'});
  $self->{'logger'}->log('Test log initialized');

  return $self;
}

sub checkExists
{
  my ($self) = @_;

  if (! -d $self->{'base_directory'})
  {
    $PRT::Logger::main_logger->log('Error: test \'' . $self->{'test_id'} . "' does not exist\n");
    die();
  }
}

1;
