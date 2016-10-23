package ALAP::Log::Simple;
use Log::Message::Simple();
use Exporter 'import';
our @EXPORT = qw(debug msg error);

our $VERBOSE = 1;
our $ENABLE  = 1;
setFlush(1);

sub setFlush {
  my $flush = shift;
  select( ( select($Log::Message::Simple::MSG_FH),   $| = $flush )[0] );
  select( ( select($Log::Message::Simple::ERROR_FH), $| = $flush )[0] );
  select( ( select($Log::Message::Simple::DEBUG_FH), $| = $flush )[0] );
}

sub msg {
  if ($ENABLE) {
    Log::Message::Simple::msg( shift, $VERBOSE );
    Log::Message::Simple->flush;
  }
}

sub debug {
  if ($ENABLE) {
    Log::Message::Simple::debug( shift, $VERBOSE );
    Log::Message::Simple->flush;
  }
}

sub error {
  if ($ENABLE) {
    Log::Message::Simple::error( shift, $VERBOSE );
    Log::Message::Simple->flush;
  }
}
