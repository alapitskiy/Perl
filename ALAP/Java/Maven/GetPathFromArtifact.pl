package ALAP::Java::Maven::GetPathFromArtifact;
use Modern::Perl;
use Cwd;
use File::Spec;

my ( $repo, $dir );

if    ( @ARGV < 1 ) { die "provide path" }
elsif ( @ARGV < 2 ) { ( $repo, $dir ) = ( getcwd(), $ARGV[0] ) }
else                { ( $repo, $dir ) = ( shift @ARGV, join '', @ARGV ) }

#say "repo: $repo  dir:$dir";
#$repo = 'D:\fuck\\';
#$dir = <<'END';
#    <groupId>com.exigen.ipb</groupId>
#    <artifactId>base-parent</artifactId>
#    <version>4.4.8</version>
#    <relativePath>../../pom.xml</relativePath>
#END

#$dir = <<'END';
#    com.exigen.ipb</groupId>
#    <artifactId>base-parent
#END

$dir =~ s/\s//msg;
#say for $dir =~ m/\>([^<]+?)\</msg;
my ($v1, $v2) = grep {$_} $dir =~ m/\>([^<]+?)\</msgc;
if (! defined $v1 ) {
  ($v1, $v2) = grep {$_} $dir =~ m/\A([^<]+?)\<|\>([^<]+?)\Z/msgc;
}
if (!defined $v1 ) {
  $v1 = $dir;
}

my $res = ($v1 // "") . '.' . ($v2 // "");
$res =~ s/\./\\/g;
$res = File::Spec->rel2abs($res,$repo);
say $res;

