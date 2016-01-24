#!/usr/bin/perl -s
#
# update_stats.pl
#
# · actualiza las estadísticas en Google Doc
# · lleva los documentos traducidos nuevos o con cambios al translated/
# · borra el que está en translated/ si es igual al que está en reviewed/
#	(eso quiere decir que los que están en reviewed/ se ponen "a mano")
# · genera un informe con el estado actual (documentos nuevos o con cambios)
# · copia la memoria de traducción al directorio del proyecto
# · copia el diccionario de nuevas palabras al dir. del proy.
#
# TODO: ¿Es posible automatizar los comandos git, o seguimos a mano? Mejor a mano... de momento.

# Joaquín Ferrero. 20110130
# Última versión:  20150831 07:42
#
# Se supone que se debe ejecutar este programa después de haber ejecutado la orden
# de generar los ficheros finales en el OmegaT, pero no es imprescindible.
#

use v5.18.2;
use common::sense;					# TODO: buscar una alternativa mejor para este módulo

use locale;
use open ':locale';

use Storable;						# para guardar y recuperar el archivo con la sesión OAuth2
use Net::Google::DataAPI::Auth::OAuth2;			# para acceder a Google
use Net::Google::Spreadsheets;

use File::Copy;
use File::Slurp;
use Digest::MD5 qw(md5_hex);
use POSIX qw'strftime locale_h';


## Configuración --------------------------------------------------------------
my $perl_version   = 'v5.22.0';
my $user           = 'explorer';			# TMX user file

# Acceso a Google
my $google_libro   = 'PerlDoc-ES.Traducción';
my $google_hoja    = $perl_version;

# Ruta a los ficheros
my $DIR_PROJECT	   = '/home/explorer/Documentos/Desarrollo/perlspanish-work';
my $DIR_GIT	   = '/home/explorer/Documentos/Desarrollo/perldoc-es';
my $DIR_GIT_TRANS  = "$DIR_GIT/pod/translated";
my $DIR_GIT_REVIEW = "$DIR_GIT/pod/reviewed";
my $DIR_GIT_TMX    = "$DIR_GIT/memory/work";
my $FILE_STATS     = "$DIR_PROJECT/omegat/project_stats.txt";
my $FILE_LIST      = "$DIR_PROJECT/files.lst";
## Fin de configuración -------------------------------------------------------

## Comprobación ---------------------------------------------------------------
-e $FILE_LIST  or die "ERROR: No encuentro el listado de archivos [$FILE_LIST]\n";
-e $FILE_STATS or die "ERROR: No encuentro el archivo de estadísticas [$FILE_STATS]\n";

## Variables ------------------------------------------------------------------
our $l;		# Opción al programa: lista los ficheros junto con sus descripciones

my @files_changed;		# archivos que han cambiado

## Leer el fichero de descripciones -------------------------------------------
my %pod_descripción_de;
for (read_file($FILE_LIST)) {
    chomp;
    my @c = split " ", $_, 2;
    $pod_descripción_de{$c[0]} = $c[1];
}

## Leer el fichero de estadísticas --------------------------------------------
my %estadísticas;
for (read_file($FILE_STATS)) {
    my @campos = split;
    next if @campos != 17;
    $estadísticas{$campos[0]} = [ @campos[1..8] ];
}

# Mostrar la lista de ficheros -----------------------------------------------
if ($l) {
    my $i = 2;				# número de fila en la hoja
    for my $fichero (sort { lc($a) cmp lc($b) } keys %estadísticas) {
	say "$i:$fichero\t$pod_descripción_de{$fichero}";
	$i++;
    }

    exit;
}


## OAuth2 ---------------------------------------------------------------------
#
# http://stackoverflow.com/questions/30476405/netgoogleauthsub-login-failed-with-new-google-drive-version
#
# I have to answer my question as I was happy to find a solution. Google changed their authentication algorithm,
# so we have to use OAuth 2.0. You will need to create Credentials at:
# https://console.developers.google.com/project/48781485103/apiui/consent
#
# APIs & auth -> Credentials -> OAuth -> Client ID -> Installed application -> Other
#
# and enable your API i.e.: APIs & auth -> APIs -> Google Apps APIs > Drive API
#
my $oauth2 = Net::Google::DataAPI::Auth::OAuth2->new(
    client_id     => '48781485103-us28tj7busq85lvhh3peeaes20.apps.googleusercontent.com',
    client_secret => 'lLoOxf9sU',
    scope         => ['http://spreadsheets.google.com/feeds/'],
);
#you can skip URL if you have your token saved and continue from RESTORE label

# RESTORE:
my $session_file = '/home/explorer/Documentos/Desarrollo/perlspanish/tools/google_spreadsheet.session';
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
    store($session, $session_file);
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

##############################################################################

## Actualizar la hoja ---------------------------------------------------------
## Leer filas
my @filas = $hoja->rows;
say scalar(@filas), " filas leídas";

#                  0    1         2      3          4        5         6      7
my @titulares = qw(seg. seg.pend. unicos unic.pend. palabras pal.pend. unicas unicaspend.);

my %archivos_traducidos_nuevos;
my %archivos_traducidos_cambios;
my %archivos_cambios;
my %archivos_traduciendo;
my %archivos_porciento;

my $min_porcen	   = 30;			## Porcentaje mínimo docs traducidos, no asignados

#open my $listado, q[>], "$dir_git/pod_traducidos.txt";

for my $i (0 .. $#filas) {
    my $fila     = $filas[$i];
    my $fila_ref = $fila->content;
    my $fichero  = $fila_ref->{'archivo'};

    if (exists $estadísticas{$fichero}) {

	my %cambios = (
	    'seg'	=> '=1-RC[-1]/RC[-2]',
	    'unico'	=> '=1-RC[-1]/RC[-2]',
	    'pal'	=> '=1-RC[-1]/RC[-2]',
	    'unica'	=> '=1-RC[-1]/RC[-2]',
	    'interes'	=> '=(RC[-11]-RC[-8])/RC[-12]',
	);

	my $hay_cambios;

	# actualización de las columnas de datos
	for my $j (0 .. $#titulares) {
	    my $tit = $titulares[$j];

	    $fila_ref->{$tit} =~ s/[.]//g;
	    if ($fila_ref->{$tit} ne $estadísticas{$fichero}[$j]) {
	        #say "$fila_ref->{$tit} ne $estadísticas{$fichero}[$j]";
		$cambios{$tit}     = $estadísticas{$fichero}[$j];
		$hay_cambios++;
	    }
	}

	# actualizar la hoja
	if ($hay_cambios) {
 	    #print "$fichero: [", $fila_ref->{'seg'}, "]\n";
 	    if ($fila_ref->{'seg'} >= 100) {
 		$archivos_traducidos_cambios{$fichero} = 1;
 	    }
 	    else {
 		$archivos_cambios{$fichero} = 1;
 	    }

	    $fila->param(\%cambios);
	    say "Actualizando $fichero";
	    push @files_changed, $fichero;
	}

	# si está completamente traducido, lo llevamos al git
	if ($estadísticas{$fichero}[1] == 0) {
	    my $origen  = "$DIR_PROJECT/target/$fichero";
	    my $targett = "$DIR_GIT_TRANS/$fichero";
	    my $targetr = "$DIR_GIT_REVIEW/$fichero";

	    my $nuevo_md5 = md5_hex(read_file($origen));
	    my $trans_md5 = -f $targett ? md5_hex(read_file($targett)) : 0;
	    my $revie_md5 = -f $targetr ? md5_hex(read_file($targetr)) : 0;

	    my $aviso_movido = 0;

	    # llevar a translated/ si no hay o está cambiado
	    if (    (!-f $targett  or  $nuevo_md5 ne $trans_md5)
		and (!-f $targetr  or  $nuevo_md5 ne $revie_md5)
	    ) {
		# Marcado en el informe
		if (!-f $targett  and  !-f $targetr) {			# si no estaba en translated/ ni en reviewed/
		    $archivos_traducidos_nuevos{$fichero} = 1;		# marcar como nuevo
		    delete $archivos_traducidos_cambios{$fichero};
		    delete $archivos_cambios{$fichero};
		}
		else {
		    $archivos_traducidos_cambios{$fichero} = 1;		# marcar solo como que cambió
		}

                # Copiar a destino
		$aviso_movido++;
		copy($origen, $targett) or die "ERROR: $!\n";		# llevar a translated/
		# git add pod/translated/$fichero

		# Ver si translated/ == reviewed/
		$trans_md5 = -f $targett ? md5_hex(read_file($targett)) : 0;

		if ($revie_md5 and $revie_md5 eq $trans_md5) {		# sí, el movido es igual
		    say "remove translated/$fichero";
		    unlink $targett;					# borramos de translated/
		    $aviso_movido = 0;
		    delete $archivos_traducidos_cambios{$fichero};	# no hay ningún cambio
		    delete $archivos_cambios{$fichero};
		}

	    }
	    else {
		delete $archivos_traducidos_cambios{$fichero};
		delete $archivos_cambios{$fichero};
	    }

	    if ($aviso_movido) {
		say "$fichero => git";
	    }
	}

	my $porcentaje = 100 * (1 - ($estadísticas{$fichero}[1] / $estadísticas{$fichero}[0]));

	if ($fila_ref->{'traductor'} and $estadísticas{$fichero}[1] > 0) {
	    $archivos_traduciendo{$fichero} = [ $fila_ref->{'traductor'}, $porcentaje ];
	}
	else {
	    if (!$fila_ref->{'traductor'} and $porcentaje >= $min_porcen) {
		$archivos_porciento{$fichero} = $porcentaje;
	    }
	}
    }
    elsif ($fichero eq 'total') {
	# TODO: Extraer información de los totales
    }
}

#close $listado;

###############################################################################

# Sacar el informe
my $informe = "$DIR_PROJECT/informe_" . strftime("%Y%m%d", localtime);

while (-f "$informe.txt") {				# evitar sobreescribir informes en el mismo día
    if ($informe =~ m/\d_(\d+)$/) {
	my $x = $1 + 1;
	$informe =~ s/\d+$/$x/;
    }
    else {
	$informe .= '_1';
    }
}

open my $REPORT, '>', "$informe.txt";

say $REPORT "\nNuevos archivos traducidos:\n";
for my $archivo (sort keys %archivos_traducidos_nuevos) {
    say $REPORT "\t$archivo";
}

say $REPORT "\nArchivos traducidos que han cambiado:\n";
for my $archivo (sort keys %archivos_traducidos_cambios) {
    say $REPORT "\t$archivo";
}

say $REPORT "\nArchivos con nuevos segmentos traducidos:\n";
for my $archivo (sort keys %archivos_cambios) {
    say $REPORT "\t$archivo";
}

say $REPORT "\nArchivos en traducción:\n";
for my $archivo (sort keys %archivos_traduciendo) {
    my($traductor, $porcentaje) = @{$archivos_traduciendo{$archivo}};
    printf $REPORT "\t%-22s (%3d %%) %s\n",  $archivo, $porcentaje, $traductor;
}

say $REPORT "\nArchivos con un mínimo del $min_porcen % sin traductor asignado:\n";
for my $archivo (sort keys %archivos_porciento) {
    my $porcentaje = $archivos_porciento{$archivo};
    printf $REPORT "\t%-22s (%3d %%)\n", $archivo, $porcentaje;
}

## Sacar los totales
#setlocale(LC_NUMERIC, "");
#sleep 3;

my($total_principal, $total, $revisado);
if (my $fila_total_principal = $hoja->row({sq => 'revisor = "Core"'})) {
    $total_principal = $fila_total_principal->content->{'pal'};
    $total_principal =~ s/,/./;
    $total_principal = sprintf "%.2f %%", $total_principal;
}

if (my $fila_total = $hoja->row({sq => 'revisor = "All"'})) {
    $total = $fila_total->content->{'pal'};
    $total =~ s/,/./;
    $total = sprintf "%.2f %%", $total;
}

if (my $fila_revisado = $hoja->row({sq => 'version = "Rev."'})) {
    $revisado = $fila_revisado->content->{'pal'};
    $revisado =~ s/,/./;
    $revisado = sprintf "%.2f %%", $revisado;
}

say $REPORT "\n\nEl proyecto está al $total ($total_principal de la documentación básica). Revisado al $revisado.";

close $REPORT;

###############################################################################
my $archivos_en_git = 0;

## Llevar la memoria de traducción al git
my $origen = (<$DIR_PROJECT/perlspanish*omegat.tmx>)[0];
my $target = "$DIR_GIT_TMX/perlspanish-omegat.$user.tmx";

if (!-f $target  or  -M $origen < -M $target) {
    copy($origen, $target) or die "ERROR: $!\n";
    say "Memoria de traducción => git";
    # git add memory/work/perlspanish-omegat.explorer.tmx
    $archivos_en_git++;
}

# Llevar el fichero de palabras nuevas
$origen = "$DIR_PROJECT/omegat/learned_words.txt";
$target = "$DIR_GIT/omegat_stuff/omegat/learned_words.txt";

if (!-f $target  or  -M $origen < -M $target) {
    copy($origen, $target) or die "ERROR: $!\n";
    say "Palabras nuevas en diccionario personal => git";
    # git add ?
    $archivos_en_git++;
}

#if ($archivos_en_git) {
# my $fecha = strftime("%Y.%m.%d %H.%M", localtime);
# my $files_changed = join " ", @files_changed;
# git commit -a -m "$perl_version $user $fecha $files_changed"
#}

###############################################################################

__END__
