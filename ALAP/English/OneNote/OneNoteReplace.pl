package ALAP::English::OneNote::OneNoteReplace;
#This doesn't work for OneNote - the replacement isn't seen by user
use Modern::Perl;
use ALAP::Utils;

my $file = $ARGV[0] or die 'Filename is expected';

my $s = getStringFromFileBin($file);
my ($replacement) = $file =~ m!(\w{3}\s\d\d-\d\d)(\.\w+)?$!;
if ($s =~ s/XXX 11-33/$replacement/) {
  say "Replacement performed";
}
putStringToFileBin($file, $s);
