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
  $self->{'base_install_script'} = 'install';

  return $self;
}

sub runTestMachine
{
  my ($self, $master_server_object) = @_;

  $self->createBaseDirectory();
  $self->createVirtualMachine();
  $self->createConfigurationFiles('client');
  $self->startMachine();
  $self->configureVirtualMachine();

  # Run main tests
  $self->runTest();

  # Destroy
  $self->stopAndDestroy();
}

sub setupMaster
{
  my ($self) = @_;

  $self->createBaseDirectory();
  $self->createVirtualMachine();
  $self->createConfigurationFiles('master');
  $self->startMachine();
  $self->configureVirtualMachine();
}

sub stopAndDestroy
{
  my ($self) = @_;

  $self->stopMachine();
  $self->destroyMachine();
  $self->deleteBaseDirectory();
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
    $self->{'logger'}->warn('VM running');
  }
}

sub runTest
{
  my ($self) = @_;

  $self->{'logger'}->log('Would run a test here');
}

sub createVirtualMachine
{
  my ($self) = @_;

  my ($exit_code, $output) = $self->runVagrantCommand('init');
  if ($exit_code)
  {
    $self->{'logger'}->error('Error creating machine:', $output);
  }
}

sub configureVirtualMachine
{
  my ($self) = @_;

  # Run the installation and configuration files
}

sub createConfigurationFiles
{
  my ($self, $install_type) = @_;

  # Create the main vagrant configuration
  $self->createVagrantConfig();

  # Copy the installation script it on the machine
  copy
  (
    $PRT::Config::SCRIPT_PATH . '/' . $self->{'base_install_script'} . '_' . $install_type,
    $self->{'base_directory'} . '/' . $self->{'base_install_script'}
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
  ) or
    $self->{'logger'}->error("Couldn't construct template: $Text::Template::ERROR");

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
    DIR => $base_directory,
    UNLINK => 0
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
    $self->runVagrantCommand('halt');
    $self->{'running'} = 0;
  }
  else
  {
    $self->{'logger'}->warn('VM already stopped');
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
      $self->{'logger'}->error('Unable to start VM:', $output);
    }

    $self->{'running'} = 1;
  }
  else
  {
    $self->{'logger'}->warn('VM already started');
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
  my $command = "VAGRANT_CWD=$vagrant_vm_path $vagrant_bin_path @args";
  $self->{'logger'}->debug("Running command: $command");
  my ($exit_code, $output) = PRT::runCommand($command, 1);

  if ($exit_code)
  {
    $self->{'logger'}->warn('Error whilst running command \'' . $command, 'Exit Code: ' . $exit_code, 'Output: ' . $output);
  }
  else
  {
    $self->{'logger'}->debug('Command output:', $output);
  }

  return ($exit_code, $output);
}

sub runVMCommand
{
  # Get arguments
  my ($self, @args) = @_;

  if ($self->{'running'})
  {
    my ($exit_code, $output) = $self->runVagrantCommand('ssh', '--command', @args);
    return ($exit_code, $output);
  }
  else
  {
    $self->{'logger'}->warn('VM not running whilst trying to perform command: ' . @args);
    return (-1, 'VM not running');
  }
}

1;
