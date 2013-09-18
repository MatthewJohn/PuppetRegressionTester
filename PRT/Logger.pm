package PRT::Logger;

use strict;
use warnings;

# Turn on autoflush
$| = 1;

use File::Touch;
use FileHandle;
use POSIX qw(strftime);
use Data::Dumper;

# Create logging directory
my $log_date = strftime("%Y%m%d_%H%M%S", localtime);
our $LOG_PATH = $PRT::Config::LOG_BASE_DIR . '/' . $log_date;
mkdir($LOG_PATH);
print "Log location: $LOG_PATH\n";

our $MAIN_LOG_NAME = 'main';

# Start main logger
our $main_logger = PRT::Logger->new();
$main_logger->log('Initialized main log');

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
  $self->{'file_name'} = $self->{'name'} || $PRT::Logger::MAIN_LOG_NAME;
  $self->{'file'} = $PRT::Logger::LOG_PATH . '/' . $self->{'file_name'};
  touch($self->{'file'});
  $self->{'LOG_FH'} = FileHandle->new($self->{'file'}, '>');

  return $self;
}

sub log
{
  my ($self, @message) = @_;

  my $log_time = strftime("%Y-%m-%d_%H:%M:%S", localtime);
  my $log_message = $log_time . ': ' . join("\n", @message) . "\n";
  print {$self->{'LOG_FH'}} $log_message;
}

sub warn
{
  my ($self, @message) = @_;

  $message[0] = 'WARNING: ' . $message[0];
  $self->log(@message);
}

sub error
{
  my ($self, @message) = @_;

  my @pre_warning_message = @message;
  $message[0] = 'FATAL: ' . $message[0];
  $self->log(@message);

  # If this is not the main logger, then log this to the main logger
  if ($self->{'file_name'} ne $PRT::Logger::MAIN_LOG_NAME)
  {
    $pre_warning_message[0] = $self->{'file_name'} . ': ' . $pre_warning_message[0];
    $PRT::Logger::main_logger->error(@pre_warning_message)
  }
  # Otherwise die with the error, so the error is sent to STDERR
  else
  {
    die(@message);
  }
}

sub DESTROY
{
  my $self = shift;
  undef $self->{LOG_FH};
}

1;
