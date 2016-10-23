package ALAP::Util::build;

use 5.010_000;
use feature ();

use strict;
use warnings;

use ALAP::Util::Lift2Array;

sub AUTOLOAD {
  $ALAP::Util::Lift2Array::AUTOLOAD = our $AUTOLOAD;
  &ALAP::Util::Lift2Array::AUTOLOAD;
}

sub concat() {
  return $_[0] . $_[1] if defined $_[1];
  return $_[0];
}

use File::Copy;
use File::Find;
use File::Spec::Functions;
use File::Path qw(make_path remove_tree);

#my $source_root     = 'E:/fproject/svn/h2/replicator/deploy/h2-replicator/';
my $source_root = 'E:\fproject\svn\releases\h2-replicator-1.3.0.BETA';

my $source_serv     = $source_root . 'server/';
my $source_serv_lib = $source_serv . 'lib';

my $dest_root = 'E:/fproject/svn/h2/replicator/deploy2/h2-replicator/';

my $dest_servs = arr_catfile( [ $dest_root, 'server' ] );
$dest_servs = arr_concat( [ $dest_servs, [ '', ( 1 .. 4 ) ] ] );

say for @$dest_servs;

my $dest_serv_libs = arr_catfile( [ $dest_servs, 'lib' ] );

# Copy libs
arr_remove_tree( [$dest_serv_libs] );
arr_copy_tree([$source_serv_lib, $dest_serv_libs]);
#find( sub { arr_copy( [ $_, $dest_serv_libs ] ) }, $source_serv_lib );

# Copy jpetstore configs

my $s_jpets = catfile( $source_root, 'examples/jpetstore' );
copy_tree(catfile($s_jpets, 'config/server1'), $dest_servs->[1]);
copy_tree(catfile($s_jpets, 'config/server2'), $dest_servs->[2]);

#system('ant');
#chdir q(..)

sub copy_tree {
  my ( $s, $d ) = @_;
  make_path($d);
  find(
    sub {
      copy( $_, make_path( $d, $File::Find::dir ) )
        if !-d && $File::Find::name !~ m/^\..*/;
    },
    $d
  );
}
