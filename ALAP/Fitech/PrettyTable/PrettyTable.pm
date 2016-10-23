package ALAP::Fitech::PrettyTable::PrettyTable;

use 5.010_000;
use feature ();

use strict;
use warnings;
use Data::Dumper;

use Text::Table;
use Text::CSV;

use Carp;

#set command line arguments
my ($infi, $outdir, $idcol) = @ARGV;

#$infi = 'E:/work/fitech/h2/tr2_my_branch/tasks/tasks.txt';
$infi = 'D:/link/dropbox/Portable/project/breakdown/bash/perl/ALAP/Fitech/PrettyTable/tasks.txt';

my $csv = Text::CSV->new({
  sep_char => "\t"
});

my $res_arr = ();

open(my $fh, "<:encoding(UTF-8)", $infi) || croak "can't open $infi: $!";

# Uncomment if you need to skip header line
 <$fh>;

while (<$fh>) {
    if ($csv->parse($_)) {
        my @columns = $csv->fields();
        push @{$res_arr}, \@columns;
#        print "$columns[0]\t$columns[1]\t$columns[2]\n";
    } else {
        my $err = $csv->error_input;
        print "Failed to parse line: $err";
    }
}
close $fh;

#say Dumper($res_arr);

sub getColumnMeta($) {
  my $title = shift;

  my $res = {
          title   => $title,
#          align   => center,
#          sample  => $sample,
#          align_title => $align_title,
          align_title => 'center',
#          align_title_lines => $align_title_lines,
  };

  return $res;
}

my $sep = {
        is_sep => 1,
        title  => ' | ',
        body   => ' | ',
};

my $tb = Text::Table->new(
  $sep,
  "Test scenario",
  $sep,
  getColumnMeta("Oracle"),
  $sep,
  getColumnMeta("MS"),
  $sep,
  getColumnMeta("Postgres"),
  $sep,
);

say $tb->body_rule('-');

#    say $tb->rule( sub { my ($index, $len) = @_; },
#               sub { my ($index, $len) = @_; },
#    );

$tb->load(
@$res_arr
#[ "Transactional logging auto commit test", '+', '+', '+'],
#[ "Hsql mem-db adaptor test", '+', '+', '+'],
);

my $rule = " +-----------------------------------------------+--------+----+----------+\n";

my @arr = $tb->body;

print $tb->title, $rule;
for (@arr) {
  print $_ . $rule;
}

# print $tb;
