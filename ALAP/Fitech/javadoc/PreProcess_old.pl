package ALAP::Fitech::javadoc::PreProcess;

use warnings;
use strict;
no strict 'subs';

use feature "switch";
use feature ":5.10";

use re 'eval';

# $\ = $/;

use constant {
  DEFAULT_ST       => 'DEFAULT',
  DESC_COMMENT_ST  => 'DESC_COMMENT',
  BLOCK_COMMENT_ST => 'BLOCK_COMMENT',
  GET_SIGN_ST      => 'GET_SIGN',
};

my $state = DEFAULT;

our $atStart  = qr!^\s*!m;
our $cInBlock = qr!${atStart}\*\s*!;
our $cDesc    = qr!${atStart}\/\*\*!;
our $cSingle  = qr!\/\/!;
our $cBlock   = qr!\/\*!;
our $cEnd     = qr!\*\/!;

sub main {
  my $processComment = shift;
  $processComment //= \&processComment;

  my $descComm  = '';
  my $signature = '';
  my $signLines = 0;

  my $line;

  while (<>) {
    $line = $_;

    if ( $state ~~ DEFAULT_ST ) {
      if ( $line =~ m/${cDesc}/ && !closedComm($line) )
      {
        $state = DESC_COMMENT_ST;
      }
      elsif ( seqRegex( qr/$cSingle/, qr/$cBlock/, $line, \&notInParen ) >= 0
      && !closedComm($line) )
      {
        $state = BLOCK_COMMENT_ST;
      }
    }
    elsif ( $state ~~ BLOCK_COMMENT_ST ) {
      if ( closedComm($line) ) {
        $state = DEFAULT_ST;
      }
    }
    elsif ( $state ~~ DESC_COMMENT_ST ) {
      if ( closedComm($line) ) {
        $state = GET_SIGN_ST;
      }

      $descComm .= $line;

      $line = undef;
    }
    elsif ( $state ~~ GET_SIGN_ST ) {
      $signature .= $line;


      $signLines++ if ($line !~ m/^\s*\@/); # java annotations

      if ( $signLines >= 3 || $line =~ m/(;|\{)(\s*|\s*${cSingle}.*)$/ ) {
        $line = $processComment->( $descComm, $signature );

        $descComm  = '';
        $signature = '';
        $signLines = 0;

        $state = DEFAULT_ST;
      } else {
        $line = undef;
      }
    }
    else {
      die "Illegal state: $state";
    }
  }
  continue {
    print "$line" if defined $line;
  }
}

our $doNotChangeMark = q(<>=.);

sub processComment {
  our $desc;
  local $desc = shift;
  my $signature = shift;

  $desc =~ s!(${cInBlock})\{\@!$1\\\{@!g;    # Replace * {@link... and their ilk

  my $sign = $signature;

  if ( $desc =~ m/\@throws|\@exception/ ) {
    $sign = cutOffComments($signature);

    my ($signThrowStr) = $sign =~ m/throws\s((?:\s*\w+\s*,)*\s*\w+)\s*[^,\s]/;

    our @signExc = ();

    if ( defined $signThrowStr ) {
      $signThrowStr =~ s/,/ /g;
      @signExc = split " ", $signThrowStr;
    }

    $desc =~
s/^(${cInBlock}\@)(throws|exception)(\s+(\w+))\b(??{if (grep {$4 eq $_} @signExc) { q((?!)); } else { q(); } })/${1}thrower$3/gm;
  }

  sub markNotChangeable {
     $desc =~ s@^(.*)(?!\Z)$@$1$doNotChangeMark@mg;
  }

  if ($desc =~ m!${cInBlock}\@see\s+\S+\#(\S+)\(.*\)! ) {
    my $procCommName = $1;

    my ($procSignName) = $sign =~ m/\A.*\b(\S+)\(.*\).*$/m;

    if (defined $procCommName and $procCommName ~~ $procSignName) {
      markNotChangeable();
    }
  } elsif ($desc =~ m!${cInBlock}\\\{\@inheritDoc\}!) {
    markNotChangeable();
  }

  return $desc . $signature;
}

sub revertComment {
  my ( $desc, $sign ) = @_;

  $desc =~ s!(${cInBlock}.*)\\(\{\@\w+\b)!$1$2!g;

  $desc =~ s!(${cInBlock}\@)thrower\b!$1throws!g;

  # if this is a method, not field
  if ( $sign =~ m!^.*\(.*\)! && $sign !~ m!^.*;! ) {
    # Places @{Inherited} into inner classes.
    # Remember that DESC_COMMENTS GO WITHOUT /**
    $desc =~ s/^(\s*\*)(\s*\n((?:\s{8}|\t\t)\s*) \*\/s*)$/$1 \{\@inheritDoc\}$2\n$3\@Override/;
  }

  if ($desc =~ m!\Q${doNotChangeMark}\E$!m ) {
    # Cuts off not markered lines.
    $desc =~ s@^.*(?<!\Q${doNotChangeMark}\E)\n(?!\Z)@@mg;


    # Cuts off markers.
    $desc =~ s!\Q${doNotChangeMark}\E$!!mg;
  }

  #if ($desc =~ m!${cInBlock}\@see \S\#(\S)\(\)! ) {
  #   my $desc0 = $desc;
  #
  #   # Cuts off the first untagged description
  #   $desc0 =~ s!${cInBlock}[^@\s].*$!!m;
  #
  #   # Cuts off tags and the next line if it's not a tag
  #   $desc0 =~ s!${cInBlock}@(?!see)\w+.*\n${atStart}\*(?!\/)\s*[^@\s].*$!!mg;
  #
  #   my $desc00 = $desc0;
  #
  #   $desc00 =~ s![\s\*\/]!!g;
  #   if ($desc00 !~ m![^\s\*\/]!)
  #}

  # Transforms the first verb.
  # Check -> Checks; Read -> Reads
  my ($titleVerb) = $desc =~ m/^\s*\*\s*(\w+)/;
  my ($signatureVerb) = $sign =~ m/\b([a-z]+2?)\w*\(/;

  if (defined $titleVerb and defined $signatureVerb) { # sing. verb can be not defined for fields, title verb for @see.
    $titleVerb = lc $titleVerb;

    if ($titleVerb eq $signatureVerb) {
      $desc =~ s/^(\s*\*\s*\w+)(?<!\d)2\b/my $start = $1; $start . q( to)/e;
      $desc =~ s/^(\s*\*\s*)(\w+)/my ($start, $name) = ($1, $2); $name =~ s@(?<!\b[tT]o)(?<=z|x|o)$@es@ || $name =~ s!(?<=sh|ch)$!es! || $name =~ s@(?<!Sa)y$@ies@ || $name =~ s@(?<!New)(?<!On)(?<!s)$@s@; $start . $name/e;
    }
  }
  # End the transformation of verbs.

  $desc =~ s/\s+the\.\n/\n/; # if there is the misadventure of having "the." at the end of the description string.

  $desc = replaceAbbr($desc, "msg", "message");
  $desc = replaceAbbr($desc, "err", "error");
  $desc = replaceAbbr($desc, "str", "string");
  $desc = replaceAbbr($desc, "e", "exception");
  $desc = replaceAbbr($desc, "ex", "exception");
  $desc = replaceAbbr($desc, "args", "arguments");
  $desc = replaceAbbr($desc, "arg", "argument");
  $desc = replaceAbbr($desc, "attrs", "attributes");
  #$desc = replaceAbbr($desc, "min", "minute"); # mininum
  $desc = replaceAbbr($desc, "mins", "minutes");
  $desc = replaceAbbr($desc, "sec", "second");
  $desc = replaceAbbr($desc, "secs", "seconds");
  $desc = replaceAbbr($desc, "sep", "separator");
  $desc = replaceAbbr($desc, "attr", "attribute");
  $desc = replaceAbbr($desc, "ctx", "context");
  $desc = replaceAbbr($desc, "ctgr", "category");
  $desc = replaceAbbr($desc, "pos", "position");
  $desc = replaceAbbr($desc, "sn", "string");
  $desc = replaceAbbr($desc, "len", "length");
  $desc = replaceAbbr($desc, "rec", "record");
  $desc = replaceAbbr($desc, "dir", "directory");
  $desc = replaceAbbr($desc, "qty", "quantity");
  $desc = replaceAbbr($desc, "prev", "previous");
  $desc = replaceAbbr($desc, "def", "definition");
  $desc = replaceAbbr($desc, "num", "number");
  $desc = replaceAbbr($desc, "arr", "array");
  $desc = replaceAbbr($desc, "cur", "current");
  $desc = replaceAbbr($desc, "ds", "datasource");
  $desc = replaceAbbr($desc, "dss", "datasources");
  $desc = replaceAbbr($desc, "seq", "sequence");
  $desc = replaceAbbr($desc, "gen", "generator");
  $desc = replaceAbbr($desc, "conn", "connection");
  $desc = replaceAbbr($desc, "stmt", "statement");
  $desc = replaceAbbr($desc, "rs", "result set");
  $desc = replaceAbbr($desc, "sess", "session");
  $desc = replaceAbbr($desc, "proc", "processor");
  $desc = replaceAbbr($desc, "auth", "authorization");
  $desc = replaceAbbr($desc, "dflt", "default");

  return $desc . $sign;
}

sub replaceAbbr {
  my ($str, $seed, $replacement) = @_;

  $seed = ucfirst $seed;
  $replacement = lcfirst $replacement;

  my $lseed = lc($seed);

  $str =~ s!(
    ${cInBlock}\s\@(?:param|exception|throws)\s+
      (?:\w\Q${seed}\E|(?<=\s)\Q${lseed}\E)(?:\W|[[A-Z]\d])
      .*?)
      \b($lseed|$seed)\b
      (.*)$!$1 . ($2 eq $lseed ? $replacement : ucfirst $replacement) . $3!megx;

  return $str;
}

sub seqRegex {
  my $check = sub { return 1; };

  if ( UNIVERSAL::isa( $_[-1], 'CODE' ) ) {
    $check = pop;
  }

  my $line  = pop;
  my $regex = pop;
  my @seq   = @_;

  my $rePos = -1;

  while ( $line =~ m/$regex/g ) {
    my $pos = pos($line) - length $&;

    if ( $check->( substr $line, 0, $rePos ) ) {
          $rePos = $pos;

            last;
        };
  }

  return -1 if $rePos < 0;

  for my $ofSeq (@seq) {
    my $ofSeqPos = -1;

    while ( $line =~ m/$ofSeq/g ) {
      my $pos = pos($line) - length $&;

      if ($check->( substr $line, 0, $ofSeqPos ) ){
            $ofSeqPos = $pos;

              last;
          };
    }

    next if $ofSeqPos < 0;

    return -1 if $ofSeqPos < $rePos;
  }

  return $rePos;
}

sub closedComm {
  my $str = shift;
  $str = '/* ' . $str;

  do { return 0; } if $str !~ m/$cEnd/;

  while (1) {
    my $pos = seqRegex( qr/$cSingle/, qr/$cBlock/, $str, \&notInParen );

    if ( $pos < 0 ) { do { return 1;} }

    $str = substr $str, $pos;

    if ( $str =~ m/$cEnd/g ) {
      $str = substr $str, pos($str);
    }
    else {
      do{ return 0; }
    }
  }
}

sub notInParen {
  my $str = shift;

  our $cnt   = 0;
  our $count = 0;

  $str =~
m/^(?{$cnt = 0;})(?>[^\\"']*)((?>\\\\|\\"|\\'|\\|'"'|'\\"'|'|"(?{local $cnt = $cnt + 1;}))(?>[^\\"']*))*(?{$count = $cnt;})$/;

  return ( $count + 1 ) % 2;
}

sub cutOffComments {
  my $str = shift;

  $str =~ s!\/\*.*?\*\/!!g;
  $str =~ s!${cSingle}.*$!!mg;

  return $str;
}
