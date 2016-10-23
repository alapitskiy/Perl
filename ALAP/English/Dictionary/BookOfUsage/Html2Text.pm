package ALAP::English::Dictionary::BookOfUsage::Html2Text;
#requires the library chilkat (chilkat.dll and chilkat.pm) put into local repo
use Modern::Perl;
use ALAP::FileUtils;
use chilkat;

use constant {
  START_DIR => "D:/link/tempf/AmHerUs",
  SELECTOR => qr/C00.*html/,
  FINISH_DIR => "D:/link/tempf/AmHerText",
};

my $conv = chilkat::CkHtmlToText->new();
$conv->UnlockComponent("anything for 30-day trial");

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

          my $inStr = new chilkat::CkString();
          $conv->ReadFileToString($_, "utf-8", $inStr);

          my $outStr = $conv->toText($inStr->getAnsi());

          say STDERR "ERROR on file $File::Find::name", return if ! defined $outStr;

          $conv->WriteStringToFile($outStr, $dest_file, "utf-8");
#          $conv->ConvertFile($_, $dest_file);
        }
      },
      preprocess => sub {
        return @_;
      },
    },
    $s
  );

say $conv->lastErrorXml();