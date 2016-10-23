package ALAP::FileUtils;
use Modern::Perl;

use File::Find;
use File::Spec;
use File::Spec::Functions;
use File::Path qw(make_path remove_tree);
use File::Basename;
use File::Copy;
use File::Slurp;
use Cwd;
use File::Where;
use Tie::File::AsHash;
use Win32::Symlink;

our @ISA = qw(File::Spec);

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

# relocates full path from sourceBase to destBase
sub cherryPick($$$) {
  my $source     = shift;
  my $sourceBase = shift;
  my $destBase   = shift;
  die 'not enough parameters' if !defined $destBase;
  my $relSource = File::Spec->abs2rel( $source, $sourceBase );
  return File::Spec->rel2abs( $relSource, $destBase );
}

sub isJunction {
  my $dir = shift;
  use ALAP::Log::Simple;
  use Win32API::File qw(:Func :FILE_ATTRIBUTE_);
  use constant DIR_ATTRS =>
    ( FILE_ATTRIBUTE_DIRECTORY | FILE_ATTRIBUTE_REPARSE_POINT );
  my $uAttrs = GetFileAttributes($dir);
  return '' if ( $uAttrs & DIR_ATTRS ) != DIR_ATTRS;
  my $link = '';
  eval { $link = readlink($dir); };

  if ( my $error = $@ ) {
    error "Error on reading junction. Tested dir: $dir \nError: $@";
  }
  return $link;
}

sub zipDir {
  use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
  use ALAP::Utils;
  my ( $source, $dest ) = @_;
  die 'Should be 2 arguments' unless defined $dest;
  tryRepeat { unlink $dest if -f $dest };
  my $zip = Archive::Zip->new();
  find(
    {
      wanted => sub {
        my $relPath = File::Spec->abs2rel( $File::Find::name, dirname $source );
        my $member = $zip->addFileOrDirectory( $File::Find::name, $relPath )
          unless $relPath eq '.';
      },
      preprocess => sub {
        use Try::Tiny;
        state $count = 0;
        $count++;
        my $junc = -d $File::Find::name
          && isJunction($File::Find::name);
        my $current = $_;
        return ()
          if $junc
            && $count != 1
            && !grep { $current eq $_; } (
              try {
                my @list = read_file(
                  File::Spec->rel2abs( '../.link_incl', $File::Find::dir ) );
                chomp @list;
                @list;
              },
              qq(..)
            );
        if ($junc) {
          my @exclusions = try {
            read_file( File::Spec->rel2abs( '.link_excl', $File::Find::dir ) );
          };
          chomp @exclusions;
          return grep { not $_ ~~ @exclusions; } @_;
        }
        return @_;
      },
    },
    $source
  );

  # Save the Zip file
  tryRepeat {
    unless ( $zip->writeToFileNamed($dest) == AZ_OK ) {
      die "write error on file: $dest";
    }
  }

}

sub getFilesInDir {
  my $dirname = shift;
  opendir my($dh), $dirname or die "Couldn't open dir '$dirname': $!";
  my @files = readdir $dh;
  closedir $dh;
  return @files;
}

sub copy_tree($$) {
  my ( $s, $d ) = @_;
  find(
    {
      wanted => sub {
        my $dest_file = cherryPick( $File::Find::name, $s, $d );
        make_path(dirname($dest_file));
        copy( $_,  $dest_file) if ! -d;
      },
      preprocess => sub {
        return grep !( m/^\.(svn|git)/ && -d ), @_;
      },
    },
    $s
  );
}

sub safe_remove_tree($) {
  my $d = shift;
  return if ! -d $d;
  find(
    {
      wanted => sub {
        unlink $_ || die "Cannot unlink $File::Find::name" if ! -d;
      },
      preprocess => sub {
        return grep !( m/^\.(svn|git)/ && -d ), @_;
      },
    },
    $d
  );
}

sub remove_svn($) {
  my $d = shift;
  find(
    {
      wanted => sub {
      },
      preprocess => sub {
        return grep { if (m/^.svn/ && -d) { tryRepeat { remove_tree $_; }; 0; } elsif(-d) {1;} else {0;} } @_;
      },
    },
    $d
  );
}