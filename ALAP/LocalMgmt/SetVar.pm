package ALAP::LocalMgmt::SetVar;
use Modern::Perl;
use ALAP::FileUtils;

use ALAP::LocalMgmt::Environment;

( my $var = shift @ARGV ) // die 'must provide variable name';

my $source = getcwd();
$source =~ s=/=\\=g;
no warnings 'once';
unless ($ALAP::LocalMgmt::Environment::undefMode) {
  system("SetX $var $source");
}
else {
  system("REG delete HKCU\Environment /V $var");
}

1;