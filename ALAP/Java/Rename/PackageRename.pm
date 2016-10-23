package ALAP::Java::Rename::PackageRename;
use Modern::Perl;
use ALAP::Java::Rename::Logger;
use ALAP::FileUtils;

sub new {
 my ($class, $subsPairs) = @_;

 my @self = @$subsPairs;

 my $self = \@self;

 bless $self, $class;

 return $self;
}

sub rename {
  my ($self, $root, $relativePath, $fileName) = @_;

  my @substs = @$self;

  for my $pair (@substs) {
    my ($pattern, $replacement) = @$pair;

    my $srcPkg = path_to_package($relativePath);

    if ($srcPkg  =~ m/\Q$pattern\E/ ) {
      #log_debug('[relative-path=' . $relativePath . '] matches [pattern=' . $pattern . ']');

      (my $destPkg = $srcPkg) =~ s/\Q$pattern\E/$replacement/;

      my $src = File::Spec->catfile($root, pkg_to_path($srcPkg));
      my $dest = File::Spec->catfile($root, pkg_to_path(destPkg));

      log_debug('Copying a dir [source=' . $src . ', destination=' . $dest . ']');

      copy_tree($src, $dest);

      rename_in_files($root, $pattern, $replacement);
    } #if
  } #for
}

sub rename_in_files {
  my ($self, $root, $pattern, $replacement) = @_;

    find(
      {
        wanted => sub {
          if (m/\.java$/) {
            my $text = read_file($_);

            $text =~ s/^(\w*package\w.*)\Q$pattern\E(.*)$/$1$replacement$2/g;

            write_file($text);

            log_debug("Renamed in file [file=" . $_ . ']');
          }
        },
        preprocess => sub {
          return grep !( m/^\.(svn|git)/ && -d ), @_;
        },
      },
      $root
    );
}

sub path_to_package {
  my $path = shift;

  $path =~ s!\/+|\\+!.!g; # C:\dir\ -> C

  $path =~ s/(?<!\.)$/./;

  $path =~ s/^(?!\.)/./;

  return $path;
}

sub pkg_to_path {
  my $pckg = shift;

  $pckg =~ s!^.!!;

  $pckg =~ s!\.!/!g; # .dir. => /dir/

  return $pckg;
}