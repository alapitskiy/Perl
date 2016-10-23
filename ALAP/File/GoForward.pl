package ALAP::File::GoForward;
use Modern::Perl;


  use Cwd;
  my $root = cwd();
  my $dir = $ARGV[0];
  $dir //= '.';
  $dir = '.' if $dir =~ m/^\.\./;
  use File::Spec;
  $dir = File::Spec->rel2abs( $dir, $root );
  $dir = File::Spec->rel2abs( '..', $dir ) if ! -d $dir;
  my $next = $dir;
 while(-d $next) {
    opendir(DIR, $dir) or die $!;
    my $stop = 0;
    my @files = grep { my $f = File::Spec->rel2abs($_, $dir); -f $f and $stop = 1; $_ !~ m/^\./ && -d $f; } readdir(DIR);
    closedir(DIR);
    last if @files != 1 || $stop;
    $next = File::Spec->rel2abs($files[0], $dir);
    $dir = $next if -d $next;
 }
print $dir;
$ENV{'goForward'}=$dir;
