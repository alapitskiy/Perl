package ALAP::Fitech::JstackStats;

use 5.010_000;
use feature ();

use strict;
use warnings;

BEGIN {
  use constant OUT_FILE => 'D:/link/tempf/jstack/profiling.out';
  use constant IN_FILE => 'D:/link/tempf/jstack/stack.6506';

  use autodie;
  # Install it with command: cpan IO::Tee
  use IO::Tee;

  # Redirects STDOUT.
  my $tee = new IO::Tee(\*STDOUT, ">" . OUT_FILE);

  select($tee);

  # Redirecs STDIN.
  open my $input, '<', IN_FILE;

  use IO::Handle;

  STDIN->fdopen($input, 'r');
}


our $method_mask = qr/at (com\.fitech|org\.h2)/;
our $thread_mask = qr/H2 TCP Server|H2 Log Writer/; # /.*/
our $dump_mask = qr/java.lang.Thread.State: (?!TIMED_WAITING \(on object monitor\))/; # /.*/

my %stat = ();

my $line_num;
my $thread_name;
my $dump;
my $hit;

while (<>) {
  if (do {$line_num = 0; m/^"/ } .. do { m/^$/ && (handle_dump(), 1) } ) {
    if ( $line_num == 0 ) {
      ($thread_name) = m/^"([^"]+?)"/;

      $dump = "\n";
      undef $hit;
    }
    else {
      if (!defined $hit && m/$method_mask/) {
        $hit = "$line_num $_";
        $hit =~ s/^\s+|\s+$//g;
      }

      $dump .= "$line_num $_";
    }

    $line_num++;
  }
}


my $all_count;

for (values %stat) {
  $all_count += $_->{count};
}

# Form result.
my @res = ();

for my $meth (keys %stat) {
  my @meth_stat = ($meth);

  # Pushes absolute and relative hits of the method.
  push @meth_stat, [$stat{$meth}{count}, sprintf('%.2f%%', $stat{$meth}{count} * 100 / $all_count)];

  {
    # Hanles stack traces.
    my @stacks = ();

    for my $stack (keys %{$stat{$meth}{stack_map}}) {
      my %stack_info = %{$stat{$meth}{stack_map}{$stack}};

      push @stacks, [$stack, $stack_info{count}, sprintf('different %d', scalar keys %{$stack_info{hash_codes}})];
    }

    # Sorts by hash count.
    @stacks = sort {$b->[1] cmp $a->[1]} @stacks;

    push @meth_stat, \@stacks;
  }
  {
    # Handles thread names.
    my @threads = ();

    for my $thread (keys %{$stat{$meth}{thread_map}}) {
        my %thread_info = %{$stat{$meth}{thread_map}{$thread}};

        push @threads, [$thread, $thread_info{count}, sprintf('different %d', scalar keys %{$thread_info{hash_codes}})];
    }

    # Sorts by hash count.
    @threads = sort {$b->[1] cmp $a->[1]} @threads;

    push @meth_stat, \@threads;
  }

  push @res, \@meth_stat;
}

# Sorts by method hit counts.
@res = sort {$b->[1][0] cmp $a->[1][0]} @res;


use Data::Dumper;

say "Method hits: $all_count";
say Dumper(\@res);


sub handle_dump {
  if ( defined $hit && $thread_name =~ m/$thread_mask/ && $dump =~/$dump_mask/ ) {
    $stat{$hit}{count}++;

    fill_entity(\%{$stat{$hit}{thread_map}}, $thread_name, \&normalize_thread);
    fill_entity(\%{$stat{$hit}{stack_map}}, $dump, \&normalize_stack);
  }
}

sub fill_entity {
  my ($map, $value, $norm_func) = @_;

  my $norm = $norm_func->($value);

  $map->{$norm}{count}++;

  $map->{$norm}{hash_codes}{$value}++;
}

sub normalize_thread {
 my $name = shift;

 # Some jstack bug.
 $name =~ s/(.*)\s+thread$/$1/;
 # Cuts off numbers in tail.
 $name =~ s/(.*)\s*\d+\s*$/$1/;

 return $name;
}

sub normalize_stack {
 my $name = shift;

 $name =~ s/<.*?>/<?>/g;

 return $name;
}
