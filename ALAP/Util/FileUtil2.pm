package ALAP::Util::FileUtil2;
use Modern::Perl;

use Exporter 'import';
our @EXPORT = qw(joinOutput);

sub joinOutput($$) {
  my $delim = shift;
  my @list  = @{ +shift };

  use Forks::Super;

  my $pid = fork { child_fh => 'out' };    # make child's STDOUT available
  if ( $pid != 0 ) {
#    return $Forks::Super::CHILD_STDOUT{$pid};

    return $pid->{child_stdout};
  }
  else {
    local $\ = undef;

    select((select(STDERR), $|=1)[0]);

    for my $file (@list) {
      use File::Basename;
      my $fileName = basename($file);

      say STDERR "Working on $fileName";

      open my $fh, '<', $file;

      my $j = 0;
      while(<$fh>) {
        do{ $j++; print "$fileName $. $_"; } if ! m/^$/;
      }
      say STDERR "fileName: $fileName j: $j";
#      close $fh;
      print "$delim\n";
    }

    print 'EOF';

    exit;
  }
}

#my $fh = joinOutput( 'fuckeRRy', [ glob(q(D:\link\tempf\test2\test.*)) ] );
#print while <$fh>;
#close $fh;
1;
