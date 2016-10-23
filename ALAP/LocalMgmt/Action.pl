package ALAP::LocalMgmt::Action;
use Modern::Perl;
use ALAP::FileUtils;
use ALAP::LocalMgmt::Environment;

my $actFile =
  File::Spec->rel2abs( $ALAP::LocalMgmt::Environment::actFile, getcwd() );

tie my %hash, 'Tie::File::AsHash', $actFile, split => ' & '
  or die "Problem tying %hash: $!";
die "provide module to execute" if !@ARGV;
my $module   = shift @ARGV;
my $args     = @ARGV ? '"' . join( '" "', @ARGV ) . '"' : '';
my $perlLine = qq(-e "require $module;" $args);

system("$^X $perlLine");
no warnings 'once';
if ($ALAP::LocalMgmt::Environment::undefMode) {
  delete $hash{"\@echo $module"};
  my $isEmpty = !%hash;
  eval 'END {unlink $actFile if $isEmpty;}';
}
else {
  $hash{"\@echo $module"} = "perl $perlLine";
}
untie %hash;
