package ALAP::Util::ImportAllSubs;

=begin
 Usage Note:
use ALAP::Util::ImportAllSubs;
{ no warnings q(once); *import = *ALAP::Util::ImportAllSubs::import;}

=cut
1;

our $fuckery = "dafa";

sub import {
  no strict 'refs';

  my $caller = caller;
  #print "_PACK_: " . __PACKAGE__ . "\n";
  #print "caller: $caller\n";
  while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
  #print "name: $name  symbol: $symbol\n";
    next if $name eq 'BEGIN';     # don't export BEGIN blocks
    next if $name eq 'import';    # don't export this sub
    next if UNIVERSAL::isa( $symbol, 'SCALAR' );    # let pass constants
    next unless *{$symbol}{CODE};                   # export subs only

    my $imported = $caller . '::' . $name;
    *{$imported} = \*{$symbol};
  }
}