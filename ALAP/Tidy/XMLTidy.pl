package ALAP::Tidy::XMLTidy;

#Works through the pipes
use Modern::Perl;

#use XML::Tidy;
use HTML::Tidy;
use File::Temp 'tempfile';
use autodie;

my $source = $ARGV[0] // '-';
do { say 'not xml file'; exit 0; } if $source !~ m/\.(xml)|\-$/i;

#my $tidy_obj = XML::Tidy->new( 'filename' => $source );
#$tidy_obj->tidy();

my $sourceContent;
if ( $source eq '-' ) {
  $sourceContent = do { local $/ = <STDIN> }
}
else {
  use File::Slurp;
  $sourceContent = read_file($source);
}

# validation
use XML::Validate;
my $validator = new XML::Validate( Type => 'LibXML' );
if ( not $validator->validate($sourceContent) ) {
  print STDERR "Document is invalid\n";
  my $message = $validator->last_error()->{message};
  my $line    = $validator->last_error()->{line};
  my $column  = $validator->last_error()->{column};
  print STDERR "Error: $message at line $line, column $column\n";
  exit 1;
}

# end validation
pre_verify($sourceContent);
add_mark($sourceContent);
my $tidy = HTML::Tidy->new(
  {
    'input-xml'      => 1,
    'output-xml'     => 1,
    indent           => 1,
    wrap             => 100,
    'indent-attributes' => 1,
    newline          => 'LF',
    'vertical-space' => 1,
  }
);
$tidy->parse( $source, $sourceContent );# or say STDERR 'Some Tidy error';
my $result = remove_mark($tidy->clean($sourceContent));
verify($result);
print $result;

#my ( $tempHandle, $tempFilename ) = tempfile(
#  'perlTidyXXXX',
#  SUFFIX => '.tmp',
#  UNLINK => 1
#);

#$tidy_obj->write($tempFilename);

#use File::Slurp;
#
#print scalar read_file $tempFilename;

BEGIN {
  my @closers;

  sub add_mark {

    #    $_[0] =~ s/\n{2,}(?!\Z)/$mark/gm;
    #    $_[0];
    our $count = 0;
    $_[0] =~
m/\>(?{$count = $count + 1;})(?=\n\n+)(?!\n+\Z)(?{push @closers, $count;})(?!)/ms;
  }

  sub remove_mark {
    our $count = 0;
    $_[0] =~
      s/\>(?{$count = $count + 1;}) (?(?{$count ~~ @closers})|(?!))/\>\n/xgms;
    $_[0];
  }

  my ($cnt_open_tag, $cnt_close_tag);
  sub pre_verify {
    $cnt_open_tag = $_[0] =~ tr/<//;
    $cnt_close_tag = $_[0] =~ tr/>//;
  }

  sub verify {
    die 'verification open tags failed' if $cnt_open_tag != $_[0] =~ tr/<//;
    die 'verification close tags failed' if $cnt_close_tag != $_[0] =~ tr/>//;
}
}
1;
