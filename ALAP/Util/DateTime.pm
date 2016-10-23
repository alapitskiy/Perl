package ALAP::Util::DateTime;

use DateTime;

use Exporter 'import';

@EXPORT = qw(getTime getDurationInMsObj getDurationInMs);

1;

sub getTime($) {
  my ( $year, $month, $day, $hour, $min, $sec, $ms ) = @{ +shift };
  return DateTime->new(
    year       => $year,
    month      => $month,
    day        => $day,
    hour       => $hour,
    minute     => $min,
    second     => $sec,
    nanosecond => $ms * 1000000,
  );
}

sub getDurationInMsObj($$) {
  my $dur = $_[0]->subtract_datetime_absolute($_[1]);
  return $dur->seconds() * 1000 + $dur->nanoseconds() / 1000000
}

sub getDurationInMs($$) {
  return getDurationInMsObj(getTime($_[0]), getTime($_[1]));
}
