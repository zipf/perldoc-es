#!/usr/bin/env perl 
#
# Actualiza la hoja de estadísticas en Google Docs, a partir de los datos
# de estadísticas del proyecto OmegaT.
#
# Joaquín Ferrero. 20110130
# Última versión:  20121103

## Módulos --------------------------------------------------------------------
use v5.16;

use autodie;
use File::Slurp;
use Net::Google::Spreadsheets;


## Configuration --------------------------------------------------------------

## Google Docs access
my $google_user   = 'emilio@gmail.com';
my $google_pass   = 'password';
my $google_file   = 'PerlDoc-ES.Traducción';
my $google_spread = 'Estadísticas';

## Path to OmegaT path
my $dir_project   = '/home/explorer/perlspanish';

my %fields        = (
    File		=> 'archivo',
    Description		=> 'desc.',
    Translator		=> 'traductor',
    Reviewer		=> 'revisor',
    Version		=> 'vers.',
    Segments		=> 'seg.',
    Seg_rest		=> 'seg.pend.',
    Seg_perc		=> 'seg',
    Uni_Seg		=> 'unicos',
    Uni_Seg_rest	=> 'unic.pend.',
    Uni_Seg_perc	=> 'unico',
    Words		=> 'palabras',
    Words_rest		=> 'pal.pend.',
    Words_perc		=> 'pal',
    Uni_Words		=> 'unicas',
    Uni_Words_rest	=> 'unicaspend.',
    Uni_Words_perc	=> 'unica',
    Priority		=> 'interes',
);

# 
my @titles = qw(
    Segments	Seg_rest	Uni_Seg		Uni_Seg_rest
    Words	Words_rest	Uni_Words	Uni_Words_rest
);

my %formulas      = (
    Seg_perc		=> '=1-RC[-1]/RC[-2]',
    Uni_Seg_perc	=> '=1-RC[-1]/RC[-2]',
    Words_perc		=> '=1-RC[-1]/RC[-2]',
    Uni_Words_perc	=> '=1-RC[-1]/RC[-2]',
    Priority		=> '=(RC[-11]-RC[-8])/RC[-12]',
);

## End of Configuration -------------------------------------------------------


## Constantes -----------------------------------------------------------------
use constant DEBUG => 1;


## Variables ------------------------------------------------------------------
my %stats;
my @rows;


## Acceso al directorio del proyecto ------------------------------------------
-d $dir_project					or die "ERROR: OmegaT project directory not found.\n";
-f "$dir_project/omegat/project_stats.txt"	or die "ERROR: OmegaT project stats file not found.\n";

# Obtener información del proyecto
for (read_file("$dir_project/omegat/project_stats.txt")) {
    my @campos = split;

    next if @campos != 17;

    $stats{$campos[0]} = [ @campos[1..8] ];
}

<<<<<<< HEAD
keys %stats or die "ERROR: Project stats unread.\n";
=======
%stats or die "ERROR: Project stats unread.\n";
>>>>>>> 19922f3cf50c1e719333154f94e9ba4a2f5f0e33


## Conexión con Google Docs ---------------------------------------------------
@rows = do {
    say "Connection..."						if DEBUG;
    my $gdoc = Net::Google::Spreadsheets->new(
	username => $google_user,
	password => $google_pass,
    );
    die "ERROR: Not access to Google Docs service: $!\n"	if not $gdoc;

    say "Access to book..."					if DEBUG;
    my $gdoc_book = $gdoc->spreadsheet({ title => $google_file });
    die "ERROR: Not access to book: $!\n"			if not $gdoc_book;

    say "Spread..."						if DEBUG;
    my $gdoc_spread = $gdoc_book->worksheet ({ title => $google_spread });
    die "ERROR: Not found stats' spreadsheet\n"			if not $gdoc_spread;

    $gdoc_spread->rows;
};


## Actualizar la hoja ---------------------------------------------------------
while (my($i,$row) = each @rows) {
    my $row_ref = $row->content;
    my $archive = $row_ref->{ $fields{'File'} };

    if (exists $stats{$archive}) {

	my $are_changes;
	my %changes = %formulas;

        # actualización de las columnas de datos
        while(my($j,$title) = each @titles) {
	    my $tit = $fields{$title};

            if ($row_ref->{$tit} ne $stats{$archive}[$j]) {
                $changes{$tit} = $stats{$archive}[$j];
                $are_changes++;
	    }
        }

        # actualizar la hoja
        if ($are_changes) {
            $row->param(\%changes);
            say "Updating $archive"				if DEBUG;
        }
    }
}


__END__
