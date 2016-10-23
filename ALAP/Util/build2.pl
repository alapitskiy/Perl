package ALAP::Util::build2;
use Modern::Perl;

{
  use ALAP::Util::Lift2Array;
  no warnings qw(once);
  *AUTOLOAD = *ALAP::Util::Lift2Array::AUTOLOAD;
}

# Prepare postgre
# SET POSTGRES_HOME=D:\DB\Postgre
# SET POSTGRES_LIB=D:\DB\Postgre\lib
# SET POSTGRES_INCLUDE=D:\DB\Postgre\include


use ALAP::Util::ExecutionTime;
use ALAP::Util::StringUtil;
use ALAP::FileUtils;

my $s = q(E:\work\fitech\h2\tr2\deploy\h2-replicator);
my $s_serv = catfile( $s, 'server' );

my $d = q(D:\link\tempf\f_deploy);
my $d_serv = arr_catfile( [ $d, arr_concat( [ 'server', [ '', 1 .. 2 ] ] ) ] );

say for @$d_serv;
#clean();
#cp_jpet();
#cp_all();
cp_part(2);


sub cp_all {
  safe_remove_tree($d);
  #copy_tree( $s, $d );


  arr_copy_tree( [ $s_serv, $d_serv ] );
}

sub clean {
#  arr_remove_tree( [ arr_catfile( [ $d_serv, "data" ] ) ] );
#  use DBD::Pg;
#  my $dbh = DBI->connect( 'DBI:Pg:dbname=h2;host=localhost',
#    'postgres', 'postgres', { 'RaiseError' => 1 } );
#  my $sth = $dbh->prepare('truncate table h2_log_repl_status');
#  $sth->execute();
#  $dbh->disconnect();

  # Restore fresh configs.
  arr_copy_tree( [
    catfile($s_serv, q(config)),
    arr_catfile([$d_serv, q(config)]),
  ]);
}

sub cp_jpet {
  my $s_jpet_conf = catfile( $s, q(examples\jpetstore\config) );

  arr_copy_tree( [ $s_jpet_conf, $d ] );

  my $d_jpet = catfile( $d, q(examples\jpetstore) );
  my $d_tomcat = q(D:\link\java\java_tools\apache-tomcat-6.0.26\webapps);

  chdir $d_jpet;
  system("ant");
  copy( catfile( $d_jpet, 'deploy/jpetstore.war' ), $d_tomcat );
  remove_tree( catfile( $d_tomcat, 'jpetstore' ) );
}

sub cp_part {
  my $ind = shift;
  my $s_conf = catfile( $s, 'examples/partition/servers' );
  $s_conf = catfile( $s_conf, qw(list modulo range) [$ind] );
  copy_tree($s_conf, $d);
}
