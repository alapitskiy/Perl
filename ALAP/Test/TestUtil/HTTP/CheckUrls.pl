package ALAP::Test::TestUtil::HTTP::CheckUrls;

use Modern::Perl;
# Checks urls from http://192.168.240.100 to http://192.168.240.120
# If urls is accessible, prints it out.

use threads;

select((select(STDOUT), $| = 1)[0]);

sub tryConnect {
  use LWP::UserAgent;
  use Try::Tiny;


   # my $url = q(http://192.168.240.102:8000);
   my $url = shift;
   say "Trying to get url: $url";
   my $ua = LWP::UserAgent->new;
   my $response;

   $ua->timeout(10);
   $response = $ua->get($url);


  #say "Code: $response->code";
  #say "Const: " . HTTP::Status::HTTP_REQUEST_TIMEOUT;

  unless ($response->is_error) {
    say "CONGRATULATIONS: $url";
  }

  if ($response->is_error) {
      # printf "[%d] %s\n", $response->code, $response->message;

      # record the timeout
      if ($response->code == HTTP::Status::HTTP_REQUEST_TIMEOUT) {
          say q(Timeout);
      }
  }
}

my @thrs;

for my $i (-5..40) {
  my $thr = threads->create( \&tryConnect, ( q(http://192.168.240.) . ( 100 + $i ) . q(:8000) ));

  push @thrs, $thr;
}

for my $thr (@thrs) {
  $thr->join();
}

say "EXECUTION COMPLETED";
