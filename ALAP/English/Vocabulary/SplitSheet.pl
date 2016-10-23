package ALAP::English::Vocabulary::SplitSheet;

# This module doesn't save format of template cells
use Modern::Perl;
use ALAP::FileUtils;
use Spreadsheet::BasicRead;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

my $sFile   = 'D:\link\dropbox\mesh\english\vocs\voc.xls';
my $dFolder = 'D:\link\tempf\eng\vocs';

#my $templateFile = 'D:\link\dropbox\mesh\english\vocs\template.xls';

# sheet name -> file
my %map = (
  'PTL'          => 'split/PTL',
  'music'        => 'split/music',
  'Insurance'    => 'split/insurance',
  'simple'       => 'split/simple',
  'phrasal'      => 'split/phrasal',
  'video'        => 'split/video',
);

my $s = Spreadsheet::ParseExcel::SaveParser->new()->Parse($sFile);
for my $sSheet ( $s->worksheets() ) {
  my $sName = $sSheet->get_name();
  next if !defined $map{$sName};

  my $dFile = File::Spec->catfile( $dFolder, $map{$sName} . '.xlsx' );
  make_path( dirname $dFile);

  # copy( $templateFile, $dFile );

  say($dFile);

  # my $d = Spreadsheet::ParseExcel::SaveParser->new()->Parse($dFile);
  # $d = $d->SaveAs($dFile);
  use Excel::Writer::XLSX;
  my $d = Excel::Writer::XLSX->new($dFile);

  #  my $dSheet = $d->sheets(0);
  my $dSheet = $d->add_worksheet();

  my ( $col_min, $col_max ) = $sSheet->col_range();
  my ( $row_min, $row_max ) = $sSheet->row_range();

  my @fs = (
    do {

      # f0
      my $f = $d->add_format();
      $f->set_size(12);
      $f->set_font('Arial Cyr');
      $f->set_align('vcenter');
      $f->set_text_wrap();
      $f;
    },
    do {

      # f1
      my $f = $d->add_format();
      $f->set_size(12);
      $f->set_font('Arial Unicode MS');
      $f->set_align('vcenter');
      $f->set_text_wrap();
      $f;
    },
    do {

      # f2
      my $f = $d->add_format();
      $f->set_size(9);
      $f->set_font('Arial Cyr');
      $f->set_align('vcenter');
      $f->set_text_wrap();
      $f;
    },
    do {

      # f3
      my $f = $d->add_format();
      $f->set_size(9);
      $f->set_font('Arial Cyr');
      $f->set_align('vcenter');
      $f->set_text_wrap();
      $f;
    },
  );

  #say "$sName $col_min , $col_max ; $row_min , $row_max";
  for my $row ( 0 .. $row_max ) {
    for my $col ( 0 .. $col_max ) {
      my $sCell = $sSheet->get_cell( $row, $col );
      if ( $sCell and $sCell->unformatted() ) {
        $dSheet->write( $row, $col, $sCell->value() );
      }
    }
  }

for my $i ( 0 .. $#fs ) {
    $dSheet->set_column( $i, $i, undef, $fs[$i] );
  }

  $dSheet->set_column( 0, 0, 12.56 );
  $dSheet->set_column( 1, 1, 12.67 );
  $dSheet->set_column( 2, 2, 32.67 );
  $dSheet->set_column( 3, 3, 32.33 );

  #$d->SaveAs($dFile);
  $d->close();
}
