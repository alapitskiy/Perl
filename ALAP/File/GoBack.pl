package ALAP::File::GoBack;
use Modern::Perl;


  use Cwd;
  my $dir = cwd();
  my $next = $dir;
 while(1) {
    $dir = File::Spec->rel2abs('..', $dir);
    opendir(DIR, $dir) or die $!;
    my $stop = 0;
    my @files = grep { my $f = File::Spec->rel2abs($_, $dir); -f $f and $stop = 1; $_ !~ m/^\./ && -d $f; } readdir(DIR);
    closedir(DIR);
    last if @files > 1 || $stop;
 }
print $dir;
$ENV{'goBack'}=$dir;