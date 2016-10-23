package ALAP::Install;
use Modern::Perl;
use autodie;
use Carp::Always;

die 'should be 2 arguments' if @ARGV != 2;
my ( $myCPANDir, $source ) = @ARGV;
$source =~ s!\\!/!g; #unix-like
die 'shoud be a ".pm" or ".pl" file ' if $source !~ m/(\.(?:pm|pl))$/i;
my $extension = $1;

#Compile check
system("$^X -c $source");
die "Compilation error, code: $? message: $@" if $? != 0;

open my $mh, "<", $source;
my ($package) = <$mh> =~ m/package\s+(ALAP::[\w:]+)\s*/;
close $mh;
die 'cant parse package header' if !$package;
$package =~ s/::/\//g;
$package .= $extension;

die 'package name and folder hierarchy are not match' if $source !~ m/\Q$package\E/;

use File::Spec;
my $dest = File::Spec->catfile($myCPANDir,$package);

use File::Path 'make_path';
use File::Basename;
make_path dirname $dest;

use File::Copy;
copy $source, $dest;

