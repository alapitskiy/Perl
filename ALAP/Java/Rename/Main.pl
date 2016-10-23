package ALAP::Java::Rename::Main;
# Isn't finished!

use Modern::Perl;

BEGIN {
use Data::Dumper;
#use ALAP::Java::Rename::PackageRename;
#*PackageRename:: = *ALAP::Java::Rename::PackageRename::;
}

{
  use ALAP::Util::Lift2Array;
  no warnings qw(once);
  *AUTOLOAD = *ALAP::Util::Lift2Array::AUTOLOAD;
}

say 'f' . allTrue(arr_t([[0, 2, 3, 4]])) . 'f';

sub t {
  return $_[0] + 1;
}


sub dp {
  say Dumper(\@_);
}