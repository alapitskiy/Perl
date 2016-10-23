package ALAP::English::Dictionary::BookOfUsage::example::Xslt;
use Modern::Perl;

my $xml = "../example/foo.xml";
my $xsl = "../example/test.xslt";

#use XML::LibXSLT::Easy;
#
#my $p = XML::LibXSLT::Easy->new;
#my $output = $p->process( xml => $xml, xsl => $xsl );
use XML::LibXSLT;
use XML::LibXML;

my $parser = XML::LibXML->new();
my $xslt   = XML::LibXSLT->new();

my $source    = $parser->parse_file($xml);
my $style_doc = $parser->parse_file($xsl);

my $stylesheet = $xslt->parse_stylesheet($style_doc);

my $results = $stylesheet->transform($source);

my $output = $stylesheet->output_string($results);

say $output;
