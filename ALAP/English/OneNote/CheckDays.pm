package ALAP::English::OneNote::CheckDays;

#Functions for checking bunches of days returned by ALAP::DateUtils::(previousDay, previousWeek) functions
use Modern::Perl;
use ALAP::Utils;
use ALAP::DateUtils;
use ALAP::FileUtils;
use List::Util qw(first);

use Exporter 'import';
our @EXPORT = qw(getEnglishDays getTechnoDays getDiaryDays getSocialDays getFileForPerMonthEnglish getFileForPerMonthTechno getFileForPerMonthDiary);

1;

sub getEnglishDays {
  return doOutput( stdoutToArray( \&ALAP::DateUtils::previousDay, @_ ),
    getFileForPerMonthEnglish() );
}

sub getTechnoDays {
  return doOutput( stdoutToArray( \&ALAP::DateUtils::previousDay, @_ ),
    getFileForPerMonthTechno() );
}

sub getDiaryDays {
  return doOutput( stdoutToArray( \&ALAP::DateUtils::previousDay, @_ ),
    getFileForPerMonthDiary() );
}

sub getSocialDays {
  return doOutput( stdoutToArray( \&ALAP::DateUtils::previousWeek, @_ ),
    getFileForPerWeekSocial() );
}

sub getFileForPerMonthEnglish {
  return getFileForPerMonth('D:/link/dropbox/mesh/OneNote/Personal/English');
}

sub getFileForPerMonthTechno {
  return getFileForPerMonth('D:/link/dropbox/mesh/OneNote/Technical');
}

sub getFileForPerMonthDiary {
  return getFileForPerMonth('D:/link/dropbox/mesh/OneNote/Diary');
}

sub getFileForPerWeekSocial {
  return getFileForPerWeek('D:/link/dropbox/mesh/OneNote/Social');
}

sub getFileForPerMonth {
  my $root = shift;
  return sub {
    my $dateStr = shift;
    my ( $year, $month, $day ) = $dateStr =~ m/^(\d{4})\s+(\w+)\s+(\d{2})/;
    my $year_dir = File::Spec->catfile( $root, $year );
    my $month_dir = File::Spec->catfile(
      $year_dir,
      first {
        m/$month/i and -d File::Spec->catfile( $year_dir, $_ );
      }
      getFilesInDir($year_dir)
    );

    my $fn = first {
      m/$day/i and -f File::Spec->catfile( $month_dir, $_ );
    }
    getFilesInDir($month_dir);
    my $full_fn = File::Spec->catfile( $month_dir, $fn );
    return $full_fn;
    }
}

sub getFileForPerWeek {
  my $root = shift;
  return sub {
    my $dateStr = shift;
    my ( $year, $fn_part ) = $dateStr =~ m/^(\d{4})\s+(.+)$/;
    my $year_dir = File::Spec->catfile( $root, $year );
    $fn_part =~ s/ /_/g;
    my $fn = first {
      m/$fn_part/i and -f File::Spec->catfile( $year_dir, $_ );
    }
    getFilesInDir($year_dir);
    my $full_fn = File::Spec->catfile( $year_dir, $fn );
    return $full_fn;
    }
}

sub doOutput {
  my $raw_output_sub = shift;
  my $get_fn_sub     = shift;
  for my $out ( $raw_output_sub->() ) {
    my ( $fn, $rexp ) = $get_fn_sub->($out);
    my $have_info_sign = -f $fn
      && getStringFromFileBin($fn) =~
      m{(\d/\d{4})|((?!11-33)(?!25-26)\d\d-\d\d)|(May.*2012)} ? '+' : '-';
    say $out . " " . $have_info_sign;
    if (  ( $have_info_sign eq '+' or defined $ENV{'backdate_path_all_files'} )
      and defined $ENV{'backdate_np_plus_plus'}
      and ( $ENV{'backdate_np_plus_plus'} eq 'np' ) )
    {
      $fn =~ s!\\!/!g;
      $fn = 'file://' . $fn;
      say STDERR $fn;
    }
  }
}
