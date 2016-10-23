package ALAP::LocalMgmt::Junc::UnPack;
use Modern::Perl;
use Getopt::Long;
use ALAP::LocalMgmt::Environment;
use ALAP::FileUtils;
use ALAP::Log::Simple;
use ALAP::Utils;

sub main {
  my $clean = '';
  GetOptions( 'clean|c' => \$clean, );

  my $sourceDir = shift @ARGV
    or die 'Specify source folder';
  my $destDir = shift @ARGV
    or die 'Specify destination folder';
  my $juncDir = shift @ARGV
    or die 'Specify junction folder';

  #  my $sourceDir = 'D:\tempFolder\zip2';
  #  my $destDir   = 'D:\tempFolder\zip';
  #  my $juncDir   = 'D:\tempFolder\zipJunc';
  if ($clean) {
    msg "Cleaning destination folder..";
    tryRepeat { remove_tree $destDir; };
    msg "Cleaning junction folder..";
    tryRepeat { remove_tree $juncDir; };
  }

  no warnings 'closure';

  find(
    {
      wanted => sub {
        my $source = $File::Find::name;
        my $dest   = cherryPick( $source, $sourceDir, $destDir );
        my $junc   = cherryPick( $source, $sourceDir, $juncDir );
        if ( -d $source ) {
          make_path($junc);
        }
        elsif ( $source =~ m/_junc\.zip$/ ) {
          $junc =~ s/(.*)_junc\.zip$/$1/;
          $dest =~ s/(.*)_junc\.zip$/$1/;
          make_path( dirname $dest);
          unzip( $source, dirname($dest) );
          require 'ALAP/LocalMgmt/Link.pl';
          ALAP::LocalMgmt::Link::make_link( $dest, dirname($junc),
            basename($junc) );
        }
        else {
          copy $source, $junc;
        }
      },
    },
    $sourceDir,
  );
}

sub unzip {
  my $source = shift;
  my $dest   = shift;
  my $zip    = Archive::Zip->new();
  use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
  say "Unzipping $source ...";
  unless ( $zip->read($source) == AZ_OK ) {
    say $source;
    die 'read error';
  }
  $zip->extractTree( '', "$dest/" );
}

main();

1;
