package PRT::VirtualMachine;

use strict;
use warnings;

use File::Temp;
use File::Copy;
use Text::Template;

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
  $self->{'running'} = 0;
  $self->{'install_script'} = 'install';

  return $self;
}

sub execute
{
  my ($self) = @_;

  $self->createBaseDirectory();
  $self->createVirtualMachine();
  $self->createConfigurationFiles();
  $self->startMachine();
  $self->configureVirtualMachine();

  $self->runTest();

  $self->stopMachine();
  $self->destroyMachine();
  $self->deleteBaseDirectory();
}

sub runTest
{
  my ($self) = @_;

  $self->{'test'}->{'logger'}->log('I would have run a test');
}

sub destroyMachine
{
  my ($self) = @_;

  if ($self->{'running'} == 0)
  {
    $self->runVagrantCommand('destroy', '-f');
    $self->{'running'} = 0;
  }
  else
  {
    print("VM not running\n");
  }
}

sub createVirtualMachine
{
  my ($self) = @_;

  my ($exit_code, $output) = $self->runVagrantCommand('init');
  if ($exit_code)
  {
    print "Error creating machine: $output\n";
  }
}

sub configureVirtualMachine
{
  my ($self) = @_;

  # Run the installation and configuration files
}

sub createConfigurationFiles
{
  my ($self) = @_;

  # Create the main vagrant configuration
  $self->createVagrantConfig();

  # Copy the installation script it on the machine
  copy
  (
    $PRT::Config::SCRIPT_PATH . '/' . $self->{'install_script'},
    $self->{'base_directory'} . '/' . $self->{'install_script'}
  );
}

sub createVagrantConfig
{
  my ($self) = @_;

  my $config_path = $self->{'base_directory'} . '/Vagrantfile';
  my $template_path = $PRT::Config::APP_BASE_DIR . '/templates/Vagrantfile.tmpl';
  my %config_variables =
  (
    'box_name' => $self->{'vm_type'}{'box_name'}
  );
  my $config_template = Text::Template->new
  (
    TYPE => 'FILE',
    SOURCE => $template_path
  ) or die "Couldn't construct template: $Text::Template::ERROR";

  my $config_output = $config_template->fill_in(HASH => \%config_variables);

  # Overwrite config file with new one from template
  open(config_file_fh, ' > ', $config_path);
  print(config_file_fh $config_output);
  close(config_file_fh);
}

sub createBaseDirectory
{
  my ($self) = @_;

  my $base_directory = $PRT::Config::APP_BASE_DIR . '/vagrant';
  my $directory_name = $self->{'vm_type'}{'dist'} . '_' . 'XXXXX';
  my $temp_dir = File::Temp->newdir
  (
    TEMPLATE => $directory_name,
    DIR => $base_directory
  );

  $self->{'base_directory'} = $temp_dir;
}

sub deleteBaseDirectory
{
  my ($self) = @_;

  unlink($self->{'base_directory'});
}

sub stopMachine
{
  my ($self) = @_; 

  if ($self->{'running'} == 1)
  {
    $self->runVagrantCommand('down');
    $self->{'running'} = 0;
  }
  else
  {
    print "VM already stopped\n";
  }
}

sub startMachine
{
  my ($self) = @_;

  if ($self->{'running'} == 0)
  {
    my ($exit_code, $output) = $self->runVagrantCommand('up');

    if ($exit_code)
    {
      die('Unable to start VM:' . $output);
    }

    $self->{'running'} = 1;
  }
  else
  {
    print "VM already started\n";
  }
}

sub runVagrantCommand
{
  # Get arguments
  my ($self, @args) = @_;

  # Get path of vagrant machine
  my $vagrant_vm_path = $self->{'base_directory'};
  my $vagrant_bin_path = $PRT::Config::VAGRANT_PATH;

  # Complile and run command and get output
  print "Running command 'VAGRANT_CWD=$vagrant_vm_path $vagrant_bin_path @args'\n";
  my $output = `VAGRANT_CWD=$vagrant_vm_path $vagrant_bin_path @args`;
  my $exit_code = $?;

  return ($exit_code, $output);
}

sub runVMCommand
{
  # Get arguments
  my ($self, @args) = @_;

  my ($exit_code, $output) = $self->runVagrantCommand('ssh', '--command', @args);
  return ($exit_code, $output);
}

1;
