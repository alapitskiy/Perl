use Test::More;
use Data::Dumper;

use feature "switch";
use feature ":5.10";

use ALAP::Utils;

BEGIN {
  require q(PreProcess.pl);
  import ALAP::Fitech::javadoc::PreProcess;
}

sub testGetAbbrFromTypeAndName {
  %res = getAbbrFromTypeAndName(
    YouFuckingBeach => "fuckingBeach",
    YouFuckingBeach => "fuckingBe",
    String => "str",
    Loh => "l",
    eol => "e",
    DejaVu => "dv",
  );

  %expected = (
     "fucking be" => "you fucking beach",
     "str" => "string",
     "dv" => "deja vu",
     "l" => "loh",
  );

  ok(eq_hash(\%res, \%expected));
}
testGetAbbrFromTypeAndName();


sub testGetNameAndTypesFromSign {
#test1
  %res = getNameAndTypesFromSign(<<'END');
    @SuppressWarnings("unchecked")
    public static <T extends Enum<T>> DefaultEntity<T> create(String id, Class<T> type) {
        return new DefaultEntity(id, type);
    }
END

  %expected = (
    String => "id",
    Class => "type",
  );

  ok(eq_hash(\%res, \%expected));

#test2
  %res = getNameAndTypesFromSign(<<'END');
    @Override
    public String getId() {
        return id;
    }
END

  %expected = ();

  ok(eq_hash(\%res, \%expected));

#test3
  %res = getNameAndTypesFromSign(<<'END');
    public void setId(String id) {
        this.id = id;
    }
END

  %expected = (String => "id");

  ok(eq_hash(\%res, \%expected));
}
testGetNameAndTypesFromSign();


sub checkWithFile {
  my ($inNm, $outNm, $resNm, $mainSign) = @_;
  my $in = getStringFromFileBin( $inNm ) ;
  my $out = getStringFromFileBin( $outNm ) ;

  unlink $resNm if -e $resNm;
  # my $res = stdoutToString(sub {stringToArgv(\&main, $in, \&revertComment, \&postProcessFields)->();})->();

  my $res = stdoutToString(sub {local @ARGV = ($inNm); $mainSign->();})->();

  if ($out ne $res) {
    putStringToFileBin( $resNm, $res );
  }

  ok($out eq $res);
}

sub genericTestFields {
  checkWithFile('preprocess_test/in1.java', 'preprocess_test/out1.java', 'preprocess_test/res1.java', sub {main(\&revertComment, \&postProcessFields);});
  checkWithFile('preprocess_test/in2.java', 'preprocess_test/out2.java', 'preprocess_test/res2.java', sub {main(\&revertComment, \&postProcessFields);});
  checkWithFile('preprocess_test/in3.java', 'preprocess_test/out3.java', 'preprocess_test/res3.java', sub {main(\&revertComment, \&postProcessFields);});
  checkWithFile('preprocess_test/in3.java', 'preprocess_test/out3.java', 'preprocess_test/res3.java', sub {main();});

  checkWithFile('preprocess_test/in_enum.java', 'preprocess_test/out_enum.java', 'preprocess_test/res_enum.java', sub {main(\&revertComment, \&postProcessFields);});
  checkWithFile('preprocess_test/in_enum2.java', 'preprocess_test/out_enum2.java', 'preprocess_test/res_enum2.java', sub {main(\&revertComment, \&postProcessFields);});
}
genericTestFields();

done_testing();

# * - file descriptor: bare name, const, scalar expression, type glob, reference to type glob. In the two last cases - reference to typeglob,
# otherwise - just a scalar (Symbol.qualify_to_ref(shift, caller) - to coerce to a typeglob reference
#