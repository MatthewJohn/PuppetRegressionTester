package PRT;

use strict;
use warnings;

#use Exporter qw(import);
#our @EXPORT_OK = qw();

use Cwd 'abs_path';
use FindBin;

sub runCommand
{
  my $command = shift;
  my $no_log = shift || 0;

  # If logging, DEBUG log the command
  unless ($no_log)
  {
    $PRT::Logger::main_logger->debug("Running command: $command");
  }

  my $output = `$command 2>&1`;
  my $exit_code = $?;

  # If logging, log any error output, else debug log the output
  unless ($no_log)
  {
    if ($exit_code)
    {
      $PRT::Logger::main_logger->warn('Error whilst running command \'' . $command, 'Exit Code: ' . $exit_code, 'Output: ' . $output);
    }
    else
    {
      $PRT::Logger::main_logger->debug('Command output:', $output);
    }
  }

  return ($exit_code, $output);
}

1;
