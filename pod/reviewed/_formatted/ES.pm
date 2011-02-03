package POD2::ES;
use warnings;
use strict;

use utf8;
use base 'POD2::Base';

our $VERSION = '5.12.3.01_2';

my $pods = {
    perlintro   => '5.12.3',
    # perl       => '5.12.3',
    # perlbook   => '5.12.3',
    # perlcheat  => '5.12.3',
    # perldata   => '5.12.3',
    # perlfunc   => '5.12.3',
    # perlstyle  => '5.12.3',
    # perlsyn    => '5.12.3',
};


sub print_pod {
    my @args = @_ ? @_ : @ARGV;

    while (@args) {
        (my $pod = lc(shift @args)) =~ s/\.pod$//;
        if ( exists $pods->{$pod} ) {
            print "\t'$pod' traducido correspondiente a Perl $pods->{$pod}\n";
        } else {
            print "\t'$pod' no existe\n";
        }
    }
}


sub search_perlfunc_re {
    return 'Lista de funciones de Perl en orden alfabético';
}

1;
__END__

=head1 NOMBRE

POD2::ES - Documentación de Perl en español

=head1 SINOPSIS

  %> perldoc POD2::ES::<nombre_de_pod>	

  use POD2::ES;
  print_pods();
  print_pod('pod_foo', 'pod_baz', ...); 

  %> perl -MPOD2::ES -e print_pods
  %> perl -MPOD2::ES -e print_pod <nombre_de_pod1> <nombre_de_pod2> ...

=head1 DESCRIPCIÓN

pod2es es el proyecto de traducción al español de la documentación básica
de Perl. Por su dimensión, es un proyecto a largo plazo.   

Vea L<http://github.com/zipf/perldoc-es> para obtener más información. 

Cuando haya instalado el paquete, puede utilizar el siguiente comando para
consultar la documentación: 

  %> perldoc POD2::ES::<nombre_de_pod>

=head1 EXTENSIÓN DE perldoc

Por desgracia, los útiles modificadores C<-f> y C<-q> de C<perldoc> no
funcionan con la documentación traducida.

Por esta razón, hemos creado una revisión de F<Pod/Perldoc.pm> 3.14 que
permite utilizar la siguiente sintaxis: 

  %> perldoc -L ES <nombre_pod>
  %> perldoc -L ES -f <función>
  %> perldoc -L ES -q <expresión regular P+F>

La revisión agrega el modificador C<-L>, que permite definir el código de
idioma para la traducción deseada. Si el paquete C<POD2::E<lt>idiomaE<gt>>
no existe, no se aplicará el modificador.

Los más perezosos pueden agregar un alias del sistema:

  perldoc-es="perldoc -L ES "

para no tener que escribir el modificador C<-L> cada vez:

  %> perldoc-es -f map 
 
Puede aplicar la revisión con la línea siguiente: 

  %> patch -p0 `/ruta_de_perl -MPod::Perldoc -e 'print
$INC{"Pod/Perldoc.pm"}'` < /ruta/Perldoc.pm-3.14-patch

La revisión se incluye con esta distribución y se encuentra en
F<./patches/Perldoc.pm-3.14-patch>.

Tenga en cuenta que la revisión es para la versión 3.14 de
L<Pod::Perldoc|Pod::Perldoc>
(incluida en Perl 5.8.7 y en Perl 5.8.8). Si tiene una distribución de Perl
anterior
(salvo la E<gt>= 5.8.1) y está impaciente por aplicar la revisión,
actualice el módulo L<Pod::Perldoc|Pod::Perldoc> a la versión 3.14.   

Consulte la API C<search_perlfunc_re> para obtener más información.

I<Nota: Perl 5.10 ya contiene esta funcionalidad, por lo que no es
necesario aplicar la revisión.>

=head1 API

El paquete exporta las siguientes funciones:

=over 4

=item * C<new>

Se ha agregado por compatibilidad con la función C<perldoc> de Perl 5.10.1.
L<Pod::Perldoc> la utiliza para devolver el nombre del paquete de
traducción.

=item * C<pod_dirs>

Se ha agregado por compatibilidad con la función C<perldoc> de Perl 5.10.1.
L<Pod::Perldoc> la utiliza para determinar dónde debe buscar los pods
traducidos.

=item * C<print_pods>

Imprime en pantalla todos los pods traducidos y la versión original de Perl
correspondiente.

=item * C<print_pod>

Imprime en pantalla la versión original de Perl correspondiente a todos los
pods pasados como argumentos.

=item * C<search_perlfunc_re>

Como el método C<search_perlfunc> de F<Pod/Perldoc.pm> utiliza la cadena
"Lista de funciones de Perl en orden alfabético" incluida en el código
(como una expresión regular) para omitir la introducción, a fin de que el
archivo de revisión funcione con otros idiomas con la opción C<-L>, hemos
utilizado un mecanismo sencillo, similar a un complemento. 

El paquete de idioma C<POD2::E<lt>idiomaE<gt>> debe exportar
C<search_perlfunc_re> para devolver una traducción de la cadena mencionada
en el párrafo anterior. Esta cadena se usará para omitir la introducción de
F<perlfunc.pod>. Si 
C<POD2::E<lt>idiomaE<gt>-E<gt>search_perlfunc_re> genera un error (o no
existe), se restablece el comportamiento predeterminado. Este mecanismo
permite agregar traducciones de C<POD2::*> adicionales sin necesidad de
aplicar cada vez la revisión de F<Pod/Perldoc.pm>.

=back

=head1 PROYECTO

Encontrará más información sobre el proyecto en
L<http://github.com/zipf/perldoc-es>.

=head1 AUTORES

=item * Joaquín Ferrero  C< explorer at joaquinferrero.com >
=item * Enrique Nell  C< blas.gordon at gmail.com E<gt >


=head1 VEA TAMBIÉN

L<POD2::PT_BR>, L<POD2::IT>, L<POD2::FR>, L<POD2::LT>, L<perl>.


=head1 ERRORES

Puede notificar errores (bugs) o solicitar funcionalidad a través de la
dirección de correo electrónico C<bug-pod2-esd at rt.cpan.org> o de la
interfaz web en L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POD2-ES>. 
Se le comunicarán automáticamente los cambios relacionados con los errores
notificados o la funcionalidad solicitada.


=head1 ASISTENCIA

Para ver la documentación de este módulo, utilice el comando perldoc.

    perldoc POD2::ES


También puede buscar información en:

=over 4

=item * RT: sistema de seguimiento de solicitudes de CPAN

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POD2-ES>

=item * AnnoCPAN: documentación de CPAN anotada

L<http://annocpan.org/dist/POD2-ES>

=item * Valoraciones de CPAN

L<http://cpanratings.perl.org/d/POD2-ES>

=item * Búsqueda de módulos de CPAN

L<http://search.cpan.org/dist/POD2-ES/>

=back


=head1 AGRADECIMIENTOS


=head1 LICENCIA Y COPYRIGHT

Copyright 2011 Equipo de Perl en Español.

Este programa es software libre; puede redistribuirlo o modificarlo bajo
los términos de la licencia GNU General Public License publicada por la
Free Software Foundation, o los de la licencia Artistic.

Consulte http://dev.perl.org/licenses/ para obtener más información.


=cut
