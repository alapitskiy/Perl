package ALAP::Fitech::javadoc::PreProcess;

use warnings;
use strict;
no strict 'subs';

use feature "switch";
use feature ":5.10";

use re 'eval';

use Data::Dumper;

# Import for tests
# use ALAP::Util::ImportAllSubs;
# { no warnings q(once); *import = \&ALAP::Util::ImportAllSubs::import;}

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

  my $processField = shift;
  $processField //= sub {my ($desc, $line) = @_; return $desc . $line;};

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
      elsif ( $line =~ m/${cDesc}/ && $line =~ m/${cEnd}\s*$/) { #supposed comment on a field
        my $desc = $line;
        while (($line = <>) =~ m/^\s*\@/) {
          $desc .= $line;
        }

        # the second condition - for annoations (but can be creating an object: List l = new ArrayList()
        #if ( $line =~ m/;\s*$/ && ( $line =~ m/=/ || $line !~ m/\(/ ) ) {
        if ($ARGV =~ m/enum/) {
       # Just for debug
       #   print STDERR "enum line: $line\n";
       #   print STDERR "seq reg: " . seqRegex(qr/=/, $line, \&notInParen) . "\n";
        }
        if ( $line =~ m/;\s*$/
             && ( seqRegex(qr/=/, $line, \&notInParen) >= 0 || $line !~ m/\(/ )
             # excludes in enums sth like "     FUNCTIONAL;"
             && ($line =~ m/\w\W+\w/) ) {
          $line = &$processField($desc, $line);
        } else {
          $line = $desc . $line;
        }
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

      if ( $signLines >= 3 || $line =~ m/(;|\{)(\s*|\s*${cSingle}.*)$/ || $line =~ m/\}/) {
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

our %abbr_replace = (
  "Constant INSTANCE" => "instance",
  "Constant log" => "logger",
  "The Constant DEBUG" => "Is debug enabled",

  "Evals" => "Evaluates",
  "Inits" => "Initializes",

  q(big (integer|decimal)) => q("big-$1"),
  q(sub (\w+)) => q("sub-$1"),

  aggr => "aggregate",
  arg => "argument",
  args => "arguments",
  arr => "array",
  async => "asynchronous",
  attr => "attribute",
  attrs => "attributes",
  auth => "authorization",
  buf => "buffer",
  buff => "buffer",
  cfg => "config",
  conn => "connection",
  ctgr => "category",
  ctx => "context",
  cur => "current",
  db => "database",
  def => "definition",
  dflt => "default",
  dir => "directory",
  ds => "datasource",
  dss => "datasources",
  e => "exception",
  err => "error",
  ex => "exception",
  expr => "expression",
  exprs => "expressions",
  gen => "generator",
  impl => "implementation",
  len => "length",
  mins => "minutes",
  msg => "message",
  num => "number",
  obj => "object",
  params => "parameters",
  pos => "position",
  prev => "previous",
  proc => "processor",
  qty => "quantity",
  rec => "record",
  rs => "result set",
  sec => "second",
  secs => "seconds",
  sep => "separator",
  seq => "sequence",
  sess => "session",
  sn => "string",
  stats => "statistics",
  stmt => "statement",
  str => "string",
);

sub revertComment {
  my ( $desc, $sign ) = @_;

  $desc =~ s!(${cInBlock}.*)\\(\{\@\w+\b)!$1$2!g;

  $desc =~ s!(${cInBlock}\@)thrower\b!$1throws!g;

  # if this is a method, not field
  if ( $sign =~ m!^.*\(.*\)! && $sign !~ m!^.*;! ) {
    # Places @{Inherited} into inner classes.
    # Remember that DESC_COMMENTS GO WITHOUT /**
    if ($sign !~ m/^.*\bprivate\b/) {
      $desc =~ s/^(\s*\*)(\s*\n((?:\s{8}|\t\t)\s*) \*\/s*)$/$1 \{\@inheritDoc\}$2\n$3\@Override/;
    }
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
      $desc =~ s/^(\s*\*\s*)(\w+)/my ($start, $name) = ($1, $2); $name =~ s@(?<!\b[tT]o)(?:(?<=z|x|o)|(?<=ss))$@es@ || $name =~ s!(?<=sh|ch)$!es! || $name =~ s@(?<!Sa)y$@ies@ || $name =~ s@(?<!New)(?<!On)(?<!To)(?<!Not)(?<!Size)(?<!(?i:uuid))(?<!s)$@s@; $start . $name/e;
    }
  }
  # End the transformation of verbs.

  $desc =~ s/\s+the\.\n/.\n/; # if there is the misadventure of having "the." at the end of the description string.

  local %abbr_replace = %abbr_replace;
  %abbr_replace = ( %abbr_replace, getAbbrFromTypeAndName(getNameAndTypesFromSign($sign)) );

  #print STDERR Dumper(\%abbr_replace);
  #my %h1 = getNameAndTypesFromSign($sign);
  #%h1 = getAbbrFromTypeAndName(%h1);
  #print STDERR Dumper(\%h1);

  $desc = replaceAbbrInMethodDesc($desc);

  return $desc . $sign;
}

sub getNameAndTypesFromSign {
  my $sign = shift;

  my @lines = $sign =~ m/^(.*\(.*\))/mg;

  @lines = grep {$_ !~ m/^\s*\@/m} @lines;

  if (! @lines) {

   # Can be class or interface
   # print STDERR "getNameAndTypesFromSign logic failed. filehandle: ${ARGV}\n";
   # print STDERR "Last line: $.\n";
   # print STDERR "@@@@@@ Signature @@@@@@\n";
   # print STDERR "$sign";
   # print STDERR "@@@@@@ End @@@@@@\n";
    return ();
  }

  my ($args) = $lines[0] =~ m/\((.*?)\)/;

  if (! $args) {
     return ();
  }

  #my @args = split /\s*,\s*/, $args;
  my @args = $args =~ m/((?:(\<(?:(?-1)|[^\<\>])*?\>)|[^,])+)(?:,|$)/g;
  @args = @args[grep {not $_ % 2} 0..$#args];
  @args = map {s/^\s+//; s/\s+$//; $_} @args;

  my %res = ();

  for my $arg (@args) {
    my ($key, undef, $value) = $arg =~ m/(?:\w+\.)*(\w+)\s*(\<(?:(?-1)|[^\<\>])*?\>)?(?:\[\s*\]\s*?)*+(?:\.\.\.)?\s+(\w+)/;

    if (! defined $key or ! defined $value) {
     print STDERR "getNameAndTypesFromSign - can't parse arg. filehandle: ${ARGV}\n";
     print STDERR "not defined key\n" if !defined $key;
     print STDERR "not defined value\n" if !defined $value;
     print STDERR "key: $key\n" if defined $key;
     print STDERR "key: $value\n" if defined $value;
     print STDERR "Last line: $.\n";
     print STDERR "@@@@@@ Signature @@@@@@\n";
     print STDERR "$sign";
     print STDERR "@@@@@@ Arg to blame @@@@@@\n";
     print STDERR "$arg\n";
     print STDERR "@@@@@@ End @@@@@@\n";
    }

    $res{$key} = $value;
  }

  return %res;
}

sub doubleHash($) {
  my %hash = %{+shift};

  my %res = ();

  while (my ($key, $value) = each %hash) {
    $res{$key} = $value;

    $res{ucfirst $key} = ucfirst $value if $key =~ m/^[a-z]/;
  }

  return %res;
}

sub replaceAbbrInMethodDesc {
  my $desc = shift;

  my $tagPat = qr/${cInBlock}\s\@(?:param|exception|throws)/;

  my ($split) = $desc =~ m/($tagPat)/;

  my ($head, $body) = split(m/$tagPat/, $desc, 2);

  if (!defined $body) {
    $body = q();

    if (!defined $head) {
      $head = $desc;
    }
  }

  if (defined $split) {
    $body = $split . $body;
  }

  # Replace in head
  if ($head !~ m/\w(?>[^\n]*)\n(?>[^\w]*)\w/) { # Comment is likely to be generated there is only one line with symbols
    my %hash = doubleHash(\%abbr_replace);
    while (my ($key, $value) = each %hash) {
      $head =~ s/\b${key}\b/if ($value =~ m!^\"!) {$value;} else {q($value);}/gee;
    }
  }

  local %abbr_replace = %abbr_replace;

  my %hash = doubleHash(\%abbr_replace);
  while (my ($key, $value) = each %hash) {
    $body =~ s/(?<!\@param )(?<!\@exception )(?<!\@throws )\b${key}\b/if ($value =~ m!^\"!) {$value;} else {q($value);}/gee;
  }

  return $head . $body;

#  $seed = ucfirst $seed;
#  $replacement = lcfirst $replacement;
#
#  my $lseed = lc($seed);
#
#  $str =~ s!(
#    ${cInBlock}\s\@(?:param|exception|throws)\s+
#      (?:\w\Q${seed}\E|(?<=\s)\Q${lseed}\E)(?:\W|[[A-Z]\d])
#      .*?)
#      \b($lseed|$seed)\b
#      (.*)$!$1 . ($2 eq $lseed ? $replacement : ucfirst $replacement) . $3!megx;
#
#  return $str;
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

    if ( $check->( substr $line, 0, $pos ) ) {
    #if ( $check->( substr $line, 0, $rePos ) ) {
          $rePos = $pos;

            last;
        };
  }

  return -1 if $rePos < 0;

  for my $ofSeq (@seq) {
    my $ofSeqPos = -1;

    while ( $line =~ m/$ofSeq/g ) {
      my $pos = pos($line) - length $&;

      if ($check->( substr $line, 0, $pos ) ){
      #if ($check->( substr $line, 0, $ofSeqPos ) ){
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

sub postProcessFields {
  my ($desc, $code) = @_;

  local %abbr_replace = %abbr_replace;

#my ($key, undef, $value) = $arg =~ m/(\w+)\s*(\<(?:(?-1)|[^\<\>])*?\>)?(?:\[\s*\])?(?:\.\.\.)?\s+(\w+)/;
  my ($type, undef, $name) = $code =~ m/^\s*(?:(?:public|protected|private|static|final)\s+)*+(?:\w+\.)*(\w+)\s*(\<(?:(?-1)|[^\<\>])*?\>)?+(?:\[\s*\]\s*?)*+\s+([_\w]+)/;

  #print STDERR "file: $ARGV   type: $type name: $name\n";

  if (!defined $type or !defined $name) {
    print STDERR "processFields logic failed. filehandle: ${ARGV}\n";
    print STDERR "Last line: $.\n";
    print STDERR "@@@@@@ Description @@@@@@\n";
    print STDERR "$desc";
    print STDERR "@@@@@@ Code @@@@@@\n";
    print STDERR "$code";
    print STDERR "@@@@@@ End @@@@@@\n";
    return $desc . $code;
  }

  %abbr_replace = (%abbr_replace, getAbbrFromTypeAndName($type, $name));

  if ($type =~ m/^[bB]oolean$/) {
    $abbr_replace{The} = q(If);
  }

  my ($annot, $desc0) = split '\/\*', (scalar reverse $desc), 2;
  $desc0 = (scalar reverse $desc0) . "\*\/";
  $annot = scalar reverse $annot;

  my %hash = doubleHash(\%abbr_replace);
  while (my ($key, $value) = each %hash) {
    $desc0 =~ s/\b${key}\b/$value/g;
  }

  return $desc0 . $annot . $code;
}

sub standardTypes {
  return (
    # not an option, because of " @throws TxDeadlockException the tx deadlock exception"
    # TxContext => "transactional context",
  );
}

sub getAbbrFromTypeAndName {
  my %type_name = @_;
  my %res = ();

  while (my ($type, $name) = each %type_name) {
    # universal replacement from a type
    my $replacement = join(q( ), map {lc} split(m/(?<=[a-z])(?=[A-Z])/, $type));

    # String str --> str, string;   YouFuckingBeach fuckBe --> fuck be, you fucking beach
    my $getContinuation = sub {
      no strict 'vars';
      local $patStr = join(q@([a-z]*)@, split m/(?<=[a-z])(?=[A-Z])/, ucfirst $name) . q@([a-z]*)@;

      $name = join(q( ), map {lc} split(m/(?<=[a-z])(?=[A-Z])/, $name));

      if ($type =~ m/$patStr/) {
        my @tails = $type =~ m/$patStr/;
        @tails = grep {$_} @tails;

        if (@tails) {
          return ($name, $replacement);
        }
      }

      return ();
    };

    my $wasSetFlag = undef;

    # dst = DataSourceTemplate -> dst -> data source template
    if ($name =~ m/^[a-z]+$/) {

      no strict 'vars';
      local $patStr = q@(@ . join(q@[a-z]+)(@, split //, uc $name) . q@[a-z]+)@;

      if ($type =~ m/\b$patStr\b/) {
        $res{$name} = $replacement;
        $wasSetFlag = 1;
      } elsif ($name =~ m/^[bcdfghjklmnpqrstvwx]+$/ || length($name) >= 3) {
        # if not abbrev, get continuation String str -> string
        my %res0 = &$getContinuation();
        if (%res0) {
          %res = (%res, %res0);
          $wasSetFlag = 1;
        }
      }

    } elsif ($name =~ m/[A-Z]/) {
      my %res0 = &$getContinuation();
      if (%res0) {
        %res = (%res, %res0);
        $wasSetFlag = 1;
      }
    }

    if (!defined $wasSetFlag) {
      my %stTypes = standardTypes();
      my $repl = $stTypes{$type};
      $res{$name} = $repl if defined $repl;
    }
  }

  return %res;
}

# Import for testing.
sub import {
  no strict 'refs';

  my $caller = caller;

  while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
    next if $name eq 'BEGIN';     # don't export BEGIN blocks
    next if $name eq 'import';    # don't export this sub
    next if UNIVERSAL::isa( $symbol, 'SCALAR' );    # let pass constants
    next unless *{$symbol}{CODE};                   # export subs only

    my $imported = $caller . '::' . $name;
    *{$imported} = \*{$symbol};
  }
}

sub debug {
  my $str = shift;
  say STDERR "!!!!! $str !!!!!";
  say STDERR for @_;
  say STDERR "!!!!! END $str !!!!!";
}
