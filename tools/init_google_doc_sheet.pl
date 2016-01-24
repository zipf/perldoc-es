#!/usr/bin/perl
#
# Inicializa la hoja de estadísticas en Google Docs.
#
# Se necesita archivos files.lst, con la lista de archivos y su descripción
# creado, sobre todo desde init_source_dir.pl
#
# Joaquín Ferrero. 20150528
#
use v5.18.2;
use common::sense;
use utf8::all;
use locale;
use open ':locale';
use File::Slurp;

use Storable;
use Net::Google::DataAPI::Auth::OAuth2;
use Net::Google::Spreadsheets;

## Configuración --------------------------------------------------------------

## Acceso a Google
my $google_libro   = 'PerlDoc-ES.Traducción';
my $google_hoja    = 'Estadísticas';

## Descripciones
my $files_lst      = '/home/explorer/Documentos/Desarrollo/perlspanish-5.22.0/files.lst';

my @titulares = (					# ATENCIÓN: debe estar en minúsculas
							# Net::Google::Spreadsheets elimina
							# caracteres extraños. Usar nombres
							# únicos para los titulares
    'archivo'		,
    'descripcion'	,
    'traductor'		,
    'revisor'		,
    'version'		,
    'seg.'		,
    'seg. pend.'	,
    '%seg'		,
    'unicos'		,
    'unic. pend.'	,
    '%unico'		,
    'palabras'		,
    'pal. pend.'	,
    '%pal'		,
    'unicas'		,
    'unicas pend.'	,
    '%unica'		,
    '%interes'		,
);

## Fin configuración ----------------------------------------------------------

## Comprobación ---------------------------------------------------------------
-e $files_lst or die "ERROR: No existe el archivo [$files_lst]: $!\n";

## Acceso a Google ------------------------------------------------------------
my $oauth2 = Net::Google::DataAPI::Auth::OAuth2->new(
    client_id     => '48781485103-us28tj7busq85iaes20.apps.googleusercontent.com',
    client_secret => 'lLoOxZgeCIpmf9sU',
    scope         => ['http://spreadsheets.google.com/feeds/'],
);

# RESTORE:
my $session_file = 'google_spreadsheet.session';
my $session;
-f $session_file and $session = retrieve($session_file);

if (! defined $session) {
    # SAVED
    my $url = $oauth2->authorize_url();
    #you will need to put code here and receive token
    print "OAuth URL, get code: $url\n";
    use Term::Prompt;
    my $code = prompt('x', 'paste the code: ', '', '');
    my $token = $oauth2->get_access_token($code) or die;

    #save token for future use
    $session = $token->session_freeze;
    store($session, 'google_spreadsheet.session');
}

my $restored_token = Net::OAuth2::AccessToken->session_thaw(
    $session,
    auto_refresh => 1,
    profile => $oauth2->oauth2_webserver,
);
$oauth2->access_token($restored_token);

## Acceso a la hoja en Google -------------------------------------------------
say "Conexión...";
my $google_docs = Net::Google::Spreadsheets->new(auth => $oauth2)
    or die "ERROR: No hay acceso al servicio Google Docs: $!\n";

say "Libro... $google_libro";
my $libro = $google_docs->spreadsheet({ title => $google_libro })
    or die "ERROR: No hay acceso al libro: $!\n";

say "Hoja... $google_hoja";
my $hoja  = $libro       ->worksheet ({ title => $google_hoja })
    or "ERROR: No encontré la hoja Traducción\n";

my @hojas = $libro->worksheets;

## Ver si la hoja ya existe ---------------------------------------------------
my $hoja;

if (grep { $_->title eq $google_hoja } @hojas) {
#     die "ERROR: La hoja [$google_hoja] ya existe\n";

    say "Hoja...";
    $hoja  = $libro->worksheet ({ title => $google_hoja });
    my $cell = $hoja->cell({col => 1, row => 2});
    die "ERROR: la segunda fila contiene algo. Borre la hoja manualmente.\n" if $cell->content;
}

## Crear la hoja --------------------------------------------------------------
else {
    say "Crear hoja...";
    $hoja = $libro->add_worksheet({
	title     => $google_hoja,
	row_count => 210,
	col_count => 18,
    });
}
die "ERROR: No encontré la hoja [$google_hoja]\n" if not $hoja;

# say "Borrado filas...";
# my @filas = $hoja->rows;			# destrucción de las filas
# my $nfila = 1;
# for my $fila (@filas) {
#     my $cell = $hoja->cell({col => 1, row => $nfila});
#     $fila->content();
#     $nfila++;
# }

## Poblar la hoja -------------------------------------------------------------
say "Poblar hoja...";
## Titulares
$hoja->batchupdate_cell( map { { col => $_+1, row => 1, input_value => $titulares[$_] } } 0 .. $#titulares );


## Resto de la hoja
my $total_archivos = 0;

for (read_file($files_lst)) {
    chomp;
    my @c = split " ", $_, 2;
    say "$c[0] => $c[1]";

    $hoja->add_row(
	    {
	    'archivo'		=> $c[0],
	    'descripcion'	=> $c[1],
	    'traductor'		=> 'explorer',
	    'revisor'		=> 'explorer',
	    'version'		=> 'v5.22.0',
	    'seg.'		=> 200,
	    'seg.pend.'		=> 100,
	    'unicos'		=> 75,
	    'unic.pend.'	=> 50,
	    'palabras'		=> 2000,
	    'pal.pend.'		=> 1000,
	    'unicas'		=> 750,
	    'unicaspend.'	=> 500,

	    'seg'		=> '=1-RC[-1]/RC[-2]',
	    'unico'		=> '=1-RC[-1]/RC[-2]',
	    'pal'		=> '=1-RC[-1]/RC[-2]',
	    'unica'		=> '=1-RC[-1]/RC[-2]',
	    'interes'		=> '=(1-RC[-10])*RC[-1]',
	}
    );
}
continue {
    $total_archivos++;
}

## Totales
my $ultima_fila_archivos = $total_archivos + 1;
$hoja->add_row(
    {
	'archivo'	=> 'total',
	'descripcion'	=> "=SUBTOTAL(103;\$A\$2:\$A\$$ultima_fila_archivos) ",
	'revisor'	=> 'Core',
	'version'	=> 'Trad.',
	'seg.'		=> "=SUBTOTAL(109;\$F\$2:\$F\$$ultima_fila_archivos) ",
	'seg.pend.'	=> "=SUBTOTAL(109;\$G\$2:\$G\$$ultima_fila_archivos) ",
	'seg'		=> '=1-RC[-1]/RC[-2]',
	'unicos'	=> "=SUBTOTAL(109;\$I\$2:\$I\$$ultima_fila_archivos) ",
	'unic.pend.'	=> "=SUBTOTAL(109;\$J\$2:\$J\$$ultima_fila_archivos) ",
	'unico'		=> '=1-RC[-1]/RC[-2]',
	'palabras'	=> "=SUBTOTAL(109;\$L\$2:\$L\$$ultima_fila_archivos) ",
	'pal.pend.'	=> "=SUBTOTAL(109;\$M\$2:\$M\$$ultima_fila_archivos) ",
	'pal'		=> '=1-RC[-1]/RC[-2]',
	'unicas'	=> "=SUBTOTAL(109;\$O\$2:\$O\$$ultima_fila_archivos) ",
	'unicaspend.'	=> "=SUBTOTAL(109;\$P\$2:\$P\$$ultima_fila_archivos) ",
	'unica'		=> '=1-RC[-1]/RC[-2]',
    }
);

$hoja->add_row(
    {
	'descripcion'	=> "=COUNTA(\$A\$2:\$A\$$ultima_fila_archivos) ",
	'revisor'	=> 'All',
	'version'	=> 'Trad.',
	'seg.'		=> "=SUM(\$F\$2:\$F\$$ultima_fila_archivos) ",
	'seg.pend.'	=> "=SUM(\$G\$2:\$G\$$ultima_fila_archivos) ",
	'seg'		=> '=1-RC[-1]/RC[-2]',
	'unicos'	=> "=SUM(\$I\$2:\$I\$$ultima_fila_archivos) ",
	'unic.pend.'	=> "=SUM(\$J\$2:\$J\$$ultima_fila_archivos) ",
	'unico'		=> '=1-RC[-1]/RC[-2]',
	'palabras'	=> "=SUM(\$L\$2:\$L\$$ultima_fila_archivos) ",
	'pal.pend.'	=> "=SUM(\$M\$2:\$M\$$ultima_fila_archivos) ",
	'pal'		=> '=1-RC[-1]/RC[-2]',
	'unicas'	=> "=SUM(\$O\$2:\$O\$$ultima_fila_archivos) ",
	'unicaspend.'	=> "=SUM(\$P\$2:\$P\$$ultima_fila_archivos) ",
	'unica'		=> '=1-RC[-1]/RC[-2]',
    }
);

my $fila_totales = $ultima_fila_archivos + 1;
my $fila_totales_siguiente = $fila_totales + 1;
$hoja->add_row(
    {
	'revisor'	=> 'Core',
	'version'	=> 'Rev.',
	'seg'		=> qq(=SUM(FILTER(\$F\$2:\$F\$$ultima_fila_archivos;\$D\$2:\$D\$$ultima_fila_archivos<>""))/\$F\$$fila_totales ),
	'unic.pend.'	=> qq(=\$I\$$fila_totales_siguiente-\$J\$$fila_totales_siguiente ),
	'unico'		=> qq(=SUM(FILTER(\$I\$2:\$I\$$ultima_fila_archivos;\$D\$2:\$D\$$ultima_fila_archivos<>""))/\$I\$$fila_totales ),
	'pal'		=> qq(=SUM(FILTER(\$L\$2:\$L\$$ultima_fila_archivos;\$D\$2:\$D\$$ultima_fila_archivos<>""))/\$L\$$fila_totales ),
	'unica'		=> qq(=SUM(FILTER(\$O\$2:\$O\$$ultima_fila_archivos;\$D\$2:\$D\$$ultima_fila_archivos<>""))/\$O\$$fila_totales ),
    }
);

$hoja->add_row(
    {
	'pal'		=> 'pals/seg',
	'unicas'	=> "=\$O\$$fila_totales/\$I\$$fila_totales ",
	'unicaspend.'	=> "=\$P\$$fila_totales/\$J\$$fila_totales ",
    }
);

__END__
