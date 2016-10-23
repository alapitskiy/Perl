package ALAP::Tidy::MyTidy;
use Modern::Perl;
use Switch;

use constant {
  perl        => 'perl',
  perl_module => 'ALAP/Tidy/PerlTidyConsole.pl',

  xml        => 'xml',
  xml_module => 'ALAP/Tidy/XMLTidy.pl',
};

my ( $source, $type ) = @ARGV;
$source //= '-';
my $test = $source;
$test = $type if $source eq '-';
undef $type;
switch ($test) {
  case /\.(pl|pm)$/i         { $type = perl }
  case /\.(xml|xhtml|xsd|iml)$/i { $type = xml }
}

die("Can't determine type of file") if ! defined $type;

my $proc = \&plain_exec;
$proc = \&piped_exec if $source ne '-';

#say "source: $source type: $type";
switch ($type) {
  case perl { &$proc( perl_module, $source ) }
  case xml { &$proc( xml_module, $source ) }
}

sub plain_exec {
  my $module = shift;
  require $module;
}

sub piped_exec {
  my $module = shift;
  my $file   = shift;

  #  use Cwd;
  #  use File::Spec;
  #  $file = File::Spec->rel2abs( $file, cwd() );
  #  say "piped";
  use File::Slurp;
  my $guts = read_file($file);

  if ( open( TO, "|-" ) ) {
    print TO $guts;
  }
  else {
    require $module;
  }
}

1;
