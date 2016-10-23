package ALAP::Util::Lift2Array;

# Calls a function with parameters taken from array.
# To make use of this package you should include it in @ISA
# our @ISA = qw(ALAP::Util::Lift2Array)

# Usage
# {
#   use ALAP::Util::Lift2Array;
#   no warnings qw(once);
#   *AUTOLOAD = *ALAP::Util::Lift2Array::AUTOLOAD;
# }

use 5.010_000;
use feature ();

use strict;
use warnings;

use Carp;

use Scalar::Util qw(blessed);

use constant prefix => 'arr_';

use Exporter 'import';
our @EXPORT = qw(allTrue);

1;

sub AUTOLOAD {
  no strict 'refs';

  my @beforeArgs;

  our $arrNum;

  if ( defined $arrNum ) {
    for my $i ( 1 .. $arrNum ) {
      push @beforeArgs, shift;
    }
  }

  my $self;
  my $arrs = shift;

  if ( defined blessed($arrs) ) {
    $self = $arrs;
    $arrs = shift;
  }

  my $fullName = our $AUTOLOAD;

  my ( $pkg, $name ) = $fullName =~ m/^(.*)::(.*)/;

  if ( !defined $pkg ) {
    $pkg  = '';
    $name = $fullName;
  }

  if ( $name !~ m/^${\(prefix)}/ ) {
    croak "Cant find such function $fullName";
  }

  $name =~ s/^${\(prefix)}//;

  *$AUTOLOAD = sub {
    my @beforeArgs;

    our $arrNum;

    if ( defined $arrNum ) {
      for my $i ( 1 .. $arrNum ) {
        push @beforeArgs, shift;
      }
    }

    my $arrs = shift;
    my @result;

    push @result, @beforeArgs;

    my $max = 0;
    $max < $#$_ && ($max = $#$_) for @$arrs;

    my $iterCnt = $max;

    for my $i ( 0 .. $#$arrs ) {
      my $scal = $arrs->[$i];

      use Scalar::Util qw(reftype);

      if ( reftype( \$scal ) eq 'SCALAR' ) {
        my @arr;
        push @arr, $scal for ( 0 .. $iterCnt );
        splice( @$arrs, $i, 1, \@arr );
      }

      #      if ( scalar @$arr == 1 ) {
      #        for my $i ( 1 .. $iterCnt ) {
      #          push @$arr, $arr->[0];
      #        }
      #      }
    }

    for my $i ( 0 .. $iterCnt ) {

      my @args;

      push @args, $self if defined $self;

      for my $j ( 0 .. $#$arrs ) {
        push @args, exists $arrs->[$j][$i] ? $arrs->[$j][$i] : '';
      }

      push @args, @_;

      $pkg = "CORE" if ! defined &{"${pkg}::${name}"};

      push @result, &{"${pkg}::${name}"}(@args);
    }

    return $result[0] if $#result == 0;
    return \@result;
  };

  unshift @_, $arrs;

  unshift @_, @beforeArgs;

  goto &$AUTOLOAD;
}

sub allTrue($) {
  my $a = shift;

  return !(grep ! $_, @$a);
}