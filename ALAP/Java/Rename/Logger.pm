package ALAP::Java::Rename::Logger;
use Modern::Perl;

use constant {
  DEBUG => 4,
  INFO => 3,
  WARN => 2,
  ERROR => 1,
};

our $lvl = DEBUG;

use Exporter 'import';
our @EXPORT = qw(log_debug log_info log_warn log_error);

1;

sub log_debug {
  if ($lvl >= DEBUG) {
     my ($package, $filename, $line) = caller;

    _print ("DEBUG", $package, $filename, $line, @_);
  }
}

sub log_info {
  if ($lvl >= INFO) {
     my ($package, $filename, $line) = caller;

    _print ("INFO", $package, $filename, $line, @_);
  }
}

sub log_warn {
  if ($lvl >= WARN) {
     my ($package, $filename, $line) = caller;

    _print ("WARN", $package, $filename, $line, @_);
  }
}

sub log_err {
  if ($lvl >= ERROR) {
     my ($package, $filename, $line) = caller;

    _print ("ERROR", $package, $filename, $line, @_);
  }
}

sub _print {
  my ($lvl, $package, $filename, $line) = (shift, shift, shift, shift);

  my $msg = shift;

  (my $fileInfo = $filename) =~ s/\.(pm|pl)$//;

  if ($lvl <= ERROR) {
    $fileInfo .= " line $line";
  }

  say "$lvl: $fileInfo - $msg";

  if ($lvl <= ERROR) {
    die "died due to logger logic";
  }
}
