package ALAP::LocalMgmt::Junc::Pack;
use Modern::Perl;
use Getopt::Long;
use ALAP::LocalMgmt::Environment;
use ALAP::FileUtils;
use ALAP::Log::Simple;
use ALAP::Utils;

sub main {
  my $sourceDir = $ALAP::LocalMgmt::Environment::root;
  my $clean     = '';
  GetOptions(
    'source|s:s' => \$sourceDir,
    'clean|c'    => \$clean,
  );

  my $destDir = shift @ARGV
    or die 'Specify destination folder';

  $sourceDir = File::Spec->rel2abs($sourceDir);
  $destDir   = File::Spec->rel2abs($destDir);

  #  $sourceDir = 'D:\link\tempf\zip';
  #  $destDir = 'D:\link\tempf\zip2';
  if ($clean) {
    msg "Cleaning destination folder..";
    tryRepeat { remove_tree $destDir; };
  }

  no warnings 'closure';

  sub getDest {
    cherryPick( +shift, $sourceDir, $destDir );
  }

  find(
    {
      wanted => sub {
        my $source = $File::Find::name;
        my $dest   = getDest($source);
        if ( -d $source ) {
          make_path($dest);
        }
        else {
          copy $source, $dest;
        }
      },
      preprocess => sub {
        use Try::Tiny;
        my @exclusions = try {
          read_file( File::Spec->rel2abs( '.link_excl', $File::Find::dir ) );
        };
        chomp @exclusions;
        return grep {
          if ( -d $_ && isJunction($_) )
          {
            say "Zipping $_ ...";
            zipDir( File::Spec->rel2abs( $_, $File::Find::dir ),
              getDest( $_ . '_junc.zip' ) );
            0;
          }
          else {
            1;
          }
        } grep { not $_ ~~ @exclusions; } grep { $_ ne '..' } @_;
      },
    },
    $sourceDir,
  );
}

sub getExclusions {
  my $dir = shift;
}

main();

1;
