package ALAP::English::Dictionary::BookOfUsage::BookOfUsage;
# Converts "The American Heritage® Book of English Usage" into lingvo dict.
use Modern::Perl;
use File::Find;

use HTML::Entities;
use Encode qw(decode encode);

use ALAP::English::Dictionary::BookOfUsage::Xslt;

use constant {
  START_DIR => "D:/link/tempf/AmHerXml",
  SELECTOR => qr/C00.*html/,
  OUT_FILE => 'D:/link/tempf/dsl/amBook.dsl',
};

my $header = <<'END'
#NAME "Book of English Usage (The American Heritage (R))"
#INDEX_LANGUAGE "English"
#CONTENTS_LANGUAGE "English"
END
;

my %entries;

my $s = START_DIR;

find(
  {
    wanted => sub {
      if (! -d && $File::Find::name =~ m/@{[SELECTOR]}/) {
         say "chosen $File::Find::name";
        my @strs = parse_file($File::Find::name);

        my @headers = map {my ($header) = m/\A(.*)$/m; $header =~ s/(^\s+)(\s+$)//g; $header} @strs;
        @strs = map {s/\A.*\n//; $_} @strs;

        @entries{@headers} = @strs;
      }
    },
  },
  $s
);

enc();

sub enc {
  #to utf-8
  my %ent2;

  while (my ($key, $value) = each %entries) {
    ($key, $value) = map {encode("utf-8", decode_entities($_))} ($key, $value);

    $ent2{$key} = $value;
  }

  %entries = %ent2;
}

write_file(\%entries);

sub write_file {
  my %hash = %{+shift};

  open my $fh, '>:raw', OUT_FILE;
  print $fh "\xFF\xFE";

  binmode $fh, ":encoding(UTF-16LE)";

  print $fh $header;

  for my $key (sort keys %hash) {
    print $fh escape($key) . "\n";
    print $fh $hash{$key} . "\n";
  }
}

sub escape {
  @_ = @_ if defined wantarray;

  $_[0] =~ s/([\@\#\(\)\{\}\[\]\\\~\<\>])/\\$1/g;

  $_[0];
}

sub print_entities {
  my $x;

  while (my ($key, $val) = each(%entries)) {
    say "KEY $key";
    say "VALUE\n$val";
    $x .= $key . "\n" . $val;
  }

  my %h;

  for my $ent ($x =~ m/(\&\#\d+;)/g) {
    $h{$ent} ++;
  }

  say "H: " . scalar keys %h;

  say "$_ ". $h{$_} . " " . encode("utf-8", decode_entities($_)) . " - " . decode_entities($_) for sort keys %h;
}

1;