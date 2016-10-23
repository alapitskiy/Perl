package ALAP::LocalMgmt::Link;

# This module creates a directory junction to a link tree
use Modern::Perl;
use ALAP::LocalMgmt::Environment;
use ALAP::FileUtils;

sub main {
  my $root = shift || $ALAP::LocalMgmt::Environment::root;
  my $source = getcwd();

  #push @ARGV, 'test/Test22';
  die 'provide link and [alias] in command line'
    if ( my ( $link, $alias ) = @ARGV ) < 1;
  make_link( $source, $root, $link, $alias );
  addkey( $alias, File::Spec->catfile( $root, $link ), $source );
}

sub make_link {
  my ( $source, $destRoot, $link, $alias ) = @_;
  die 'provide at least 3 arguments' if !defined $link;
  $link = File::Spec->catfile( dirname($link), lc basename $link);

  $alias = $alias // basename $link;
  my $linkpath = File::Spec->catfile( $destRoot, $link );

  #create link
  make_path dirname $linkpath;
  symlink( $source => $linkpath ) || die "Error creating symlink";

  #create callback link
  my $linkbackPath = do {
    no warnings 'once';
    File::Spec->catfile( $source, $ALAP::LocalMgmt::Environment::backLinkName );
  };

  use Win32::OLE;

  my $wsh = new Win32::OLE 'WScript.Shell';
  my $shcut = $wsh->CreateShortcut($linkbackPath) or die;
  $source =~ tr!/!\\!;
  $shcut->{'TargetPath'}        = '%systemroot%\explorer.exe';
  $shcut->{'Arguments'}         = "/n, $source";
  $shcut->{'Description'}       = 'Linkback to original directory';
  $shcut->{'WindowStyle'}       = 1;
  $shcut->{'WorkingDirectory '} = '';
  $shcut->Save;
}

#addkey
sub addkey {
  my ( $alias, $linkpath, $source ) = @_;
  system("addkey $alias=pushd $linkpath");
  system("addkey ${alias}_s=pushd $source");
}

#create recalling file
1;
