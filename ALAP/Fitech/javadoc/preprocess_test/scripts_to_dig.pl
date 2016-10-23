print "Start\n";
sub lineNumbers {
  my $arg = shift;

  print "ARGV: @ARGV\n";

  while(<>) {
    print "f $arg$. $_";
  }
}
#my $res = stringToStdin(\&lineNumbers, <<'END', "fuck");
#END

my $res = stdoutToString(sub {stringToArgv(\&lineNumbers, <<'END', "fuck")->()})->();
ol
lolol
ololashechka
END

print "RES:\n$res";
