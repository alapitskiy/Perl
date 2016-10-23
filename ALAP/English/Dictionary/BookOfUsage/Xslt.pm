package ALAP::English::Dictionary::BookOfUsage::Xslt;
use Modern::Perl;

#use XML::LibXSLT::Easy;
#
#my $p = XML::LibXSLT::Easy->new;
#my $output = $p->process( xml => $xml, xsl => $xsl );
use XML::LibXSLT;
use XML::LibXML;

use Exporter 'import';
our @EXPORT = qw(parse_file);

XML::LibXSLT->register_function( "urn:func", "my_remove_ws",
  sub { my $s = shift; $s =~ s/\n\s{2,}$//; $s =~ s/[\r\n]//; return $s } );

#XML::LibXSLT->register_function("urn:debug", "debug", sub {say for @_});
sub parse_file {
  my $xml = shift // "example/foo.xml";

  #  my $xsl = "Xml2dict.xslt";
  my $xsl =
"D:/link/programming/jcurrent/breakdown/bash/perl/ALAP/English/Dictionary/BookOfUsage/Xml2dict.xslt";

  my $parser = XML::LibXML->new();
  my $xslt   = XML::LibXSLT->new();

  my $source    = $parser->parse_file($xml);
  my $style_doc = $parser->parse_file($xsl);

  my $stylesheet = $xslt->parse_stylesheet($style_doc);

  $stylesheet->register_element(
    "urn:debug",
    "debug",
    sub {
      say $_[2]->textContent;
      my $res = XML::LibXML::Element->new("debug");
      $res->appendText( $_[2]->textContent );
      return $res;
    }
  ) if 1 == 0;

  my $results =
    $stylesheet->transform( $source,
    XML::LibXSLT::xpath_to_string( filename => $xml ) );

  my $output = $stylesheet->output_string($results);

  $output = post_process($output);

  return split_multiples($output);
}

#say parse_file();

sub post_process {
  my $str = shift;

  $str =~ s/\][ \t]+/\] /g;
  $str =~ s!(?<=\[\/b\])\s+!!g;

  #inserts [m1] with main entries
  $str =~ s!^(\t)(\[b\].*)$!${1}[m1]${2}[/m]!gm;

  # correct some tags without section number ([b]. [/b])
  $str =~ s!(?<=\[m1\])\[b\]\. \[\/b\]!!g;


  #Avoids Error "Empty Headword" while compiling.
  $str =~ s!^\s*\n!!gm;

  #Escapes square brackets if not tags
  $str =~ s!(\[.*?\])! if ( grep {$1 =~ m/$_/} qw@\\[\\/ \\[b\\] \\[i\\] \\[u\\] \\[ex\\] \\[m\\d\\] \\[g\\] \\[\\*\\]@, "\\[c " ) {
     $1;
  } else {
     my $res = "\\" . $1;
     $res =~ s/\]$/\\\]/;
     $res;
  }
  !xge;

  #LaF - examples in the main text blue and quoted
  {
    my $s2;

    do {
      $s2 = $str;

      $str =~ s@^(\s*\[m1\].*\[i\])(?!\")(.*?)(?!\")(\[\/i\].*)$@$1\"\[c darkblue\]$2\[\/c\]\"$3@gm;
    } while $str ne $s2;
  }

  # delete number of chapter from section (subtitle)
  $str =~ s!(?<=\[m0\]\[\*\]\[ex\])\s*\d+\.\s*!!g;

  # substitute images (the [g] tag)
#  use ALAP::English::Dictionary::BookOfUsage::Util::SgmlSupport;
#  $str =~ s!\[g\].*?\/([^\/]*)\.gif\[\/g\]!$ent{$1}!g;

  # escape #'s, because of lingvo's error 'preprocessor directive'
  $str =~ s@(?<!&)#(?!\d)@\\#@g;

  return $str;
}

sub split_multiples {
  my $str = shift;

  my ($header) = $str =~ m/\A(.*)$/m;
  ( my $body = $str ) =~ s/\A.*$//m;

  my @res;

  my @heads = split( m!\s*\/\s*!, $header );

  for my $i ( 0 .. $#heads ) {
    my $head  = $heads[$i];
    my $body2 = $body;

    if ( @heads > 1 ) {
      my @others = @heads[ 0 .. $i - 1, $i + 1 .. $#heads ];

      $body2 =
          "\n\t[m0](also "
        . join( " / ", map "[b][c blue]${_}[/c][/b]", @others ) . ")[/m]"
        . $body;
    }

    if ( scalar split( m!\s*\/s*!, $header ) > 10 ) {
      say "SPLIT for $header";
      say "b${head}b";
      say "$body";
    }
    push @res, ( $head . $body2 );
  }

  return @res;
}
1;
