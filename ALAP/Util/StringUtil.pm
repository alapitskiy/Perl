package ALAP::Util::StringUtil;
use Modern::Perl;

1;

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

sub concat($) {
  return $_[0] . $_[1] if defined $_[1];
  return $_[0];
}