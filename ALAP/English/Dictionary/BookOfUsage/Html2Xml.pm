package ALAP::English::Dictionary::BookOfUsage::Html2Xml;
#requires the library chilkat (chilkat.dll and chilkat.pm) put into local repo
use Modern::Perl;
use ALAP::FileUtils;
use chilkat;

use constant {
  START_DIR => "D:/link/tempf/AmHerUs",
  SELECTOR => qr/C00.*html/,
  FINISH_DIR => "D:/link/tempf/AmHerXml",
};

my $conv = chilkat::CkHtmlToXml->new();
$conv->UnlockComponent("anything for 30-day trial");
$conv->UndropTextFormattingTags();

#$conv->ConvertFile("005.html", "1/005.xhtml");
my $s = START_DIR;
my $d = FINISH_DIR;

  find(
    {
      wanted => sub {
        my $dest_file = cherryPick( $File::Find::name, $s, $d );

#        say "trying $File::Find::name";
        if (! -d && $File::Find::name =~ m/@{[SELECTOR]}/) {
#          say "chosen $File::Find::name";
          make_path(dirname($dest_file));
          $conv->ConvertFile($_, $dest_file);
        }
      },
      preprocess => sub {
        return @_;
      },
    },
    $s
  );

say $conv->lastErrorXml();