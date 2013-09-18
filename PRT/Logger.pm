package PRT::Logger;

use strict;
use warnings;

use File::Touch;
use FileHandle;
use POSIX qw(strftime);

my $log_date = strftime("%Y%m%d_%H%M%S", localtime);
our $log_path = $PRT::Config::LOG_BASE_DIR . '/' . $log_date;
mkdir($log_path);
print "Log location: $log_path\n";

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
  $self->{'file_name'} = $self->{'name'} || 'main';
  $self->{'file'} = $PRT::Logger::log_path . '/' . $self->{'file_name'};
  touch($self->{'file'});
  $self->{'LOG_FH'} = FileHandle->new($self->{'file'}, '>');

  return $self;
}

sub log
{
  my ($self, $message) = @_;

  my $append = strftime("%Y%m%d %H:%M:%S", localtime);
  my $log_message = $append . $message . "\n";
  print {$self->{'LOG_FH'}} $log_message;
}

sub DESTROY
{
  my $self = shift;
  undef $self->{LOG_FH};
}

1;
