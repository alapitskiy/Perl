package ALAP::Utils;

use Modern::Perl;

use Exporter 'import';
our @EXPORT =
  qw(tryRepeat Dumper getStringFromFile putStringToFile getStringFromFileBin putStringToFileBin stdoutToArray stdoutToString stringToStdin stringToArgv);

1;

use Data::Dumper;

sub getMonitor($) {
  use ProgressMonitor::Stringify::ToStream;
  use ProgressMonitor::Stringify::Fields::Bar;
  use ProgressMonitor::Stringify::Fields::Fixed;
  use ProgressMonitor::Stringify::Fields::Percentage;
  use ProgressMonitor::Stringify::Fields::ETA;
  my $monitor = ProgressMonitor::Stringify::ToStream->new(
    {
      fields => [
        ProgressMonitor::Stringify::Fields::Bar->new,
        ProgressMonitor::Stringify::Fields::Fixed->new,
        ProgressMonitor::Stringify::Fields::Percentage->new,
        ProgressMonitor::Stringify::Fields::ETA->new,
      ],
      stream => \*STDERR,
    }
  );
  $monitor->prepare();
  $monitor->begin(shift);
  return $monitor;
}

#File utils

sub getStringFromFile {
  my $fileName = shift;
  local $/ = undef;
  open my $FILE, $fileName or die "Couldn't open file: $!";
  my $string = <$FILE>;
  close $FILE;
  return $string;
}

sub putStringToFile($$) {
  my $fileName = shift;
  my $str      = shift;
  local $/ = undef;
  open my $FILE, ">$fileName" or die "Couldn't open file: $!";
  print $FILE $str;
  close $FILE;
}

sub getStringFromFileBin($) {
  my $fileName = shift;
  local $/ = undef;
  open my $FILE, $fileName or die "Couldn't open file: $!";
  binmode $FILE;
  my $string = <$FILE>;
  close $FILE;
  return $string;
}

sub putStringToFileBin($$) {
  my $fileName = shift;
  my $str      = shift;
  local $/ = undef;
  open my $FILE, ">$fileName" or die "Couldn't open file: $!";
  binmode $FILE;
  print $FILE $str;
  close $FILE;
}

sub getArrayFromFile($) {
  my $fileName = shift;
  open my $FILE, $fileName or die "Couldn't open file: $!";
  my @string = <$FILE>;
  close $FILE;
  return \@string;
}

#Collection utils

sub hashToHash($$) {
  my $in  = shift;
  my $res = shift;
  for my $key ( keys %$in ) {
    $res->{$key} = $in->{$key};
    delete $in->{$key};
  }
}

#Time utils

sub cutTime($) {
  use Date::Parse;
  my ( $ss, $mm, $hh, $day, $month, $year, $zone ) = strptime(shift);
  return ( split /\./, "${hh}:${mm}:${ss}", 2 )[0];
}

sub tryRepeat(&) {
  my $code   = shift;
  my $errMsg = shift;
  while (1) {
    eval { &$code(); };
    last unless ( my $error = $@ );
    say "@{[$errMsg // $error]}";
    say
'Enter any line and press enter to get another try, or type "skip" to skip';
    my $x = <>;
    chomp($x);
    last if lc($x) eq 'skip';
  }
}

sub stdoutToArray(&;@) {
  my $code   = shift;
  my @params = @_;
  return sub {
    my $var;
    local *STDOUT;
    open( STDOUT, '>', \$var ) || die "Unable to open STDOUT: $!";
    &$code(@params);
    close(STDOUT);
    return split( "\n", $var );
  };
}

sub stdoutToString(&;@) {
  my $code   = shift;
  my @params = @_;
  return sub {
    my $var;
    local *STDOUT;
    open( STDOUT, '>', \$var ) || die "Unable to open STDOUT: $!";
    &$code(@params);
    close(STDOUT);
    return $var;
  };
}

sub stringToStdin(&$;@) {
  my $code   = shift;
  my $var = shift;

  my @params = @_;
  return sub {
    local *STDIN;
    open( STDIN, '<', \$var ) || die "Unable to open STDIN: $!";
    my @res = &$code(@params);
    close(STDIN);
    return @res;
  };
}

sub stringToArgv(&$;@) {
  my $code  = shift;
  my $var = shift;

  my @params = @_;
  return sub {
    use File::Temp 'tempfile';

    my ( $tempHandle, $tempFilename ) = tempfile(
      'stringToArgvXXXX',
      SUFFIX => '.tmp',
      UNLINK => 1 # close on object destructor
    );

    putStringToFile($tempFilename, $var);
    local @ARGV = ($tempFilename);

    my $res = \&$code(@params);

    $tempHandle->close();

    return $$res;
  }
}