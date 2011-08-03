package POD2::ES;
use warnings;
use strict;

use base 'POD2::Base';

our $VERSION = '5.14.1.05';

sub search_perlfunc_re {
    return 'Lista de funciones de Perl en orden alfabético';
}

sub pod_info {{
    perl        => '5.14.1',
    perlbook    => '5.14.1',
    perlcheat   => '5.14.1',
    #perldata    => '5.14.1',
    perlfaq1    => '5.14.1',
    perlfaq2    => '5.14.1',
    perlintro   => '5.14.1',
    perlnumber  => '5.14.1',
    perlunitut  => '5.14.1',
    perlutil    => '5.14.1',
    'README.freebsd'  => '5.14.1',
    'README.openbsd'  => '5.14.1',
    # perlfunc   => '5.14.1',
    # perlstyle  => '5.14.1',
    # perlsyn    => '5.14.1',
}};

sub print_pod {
    my $self = shift;
    my @args = @_ ? @_ : @ARGV;

    my $pods = $self->pod_info;
    while (@args) {
        (my $pod = lc(shift @args)) =~ s/\.pod$//;
        if ( exists $pods->{$pod} ) {
            print "\t'$pod' traducido correspondiente a Perl $pods->{$pod}\n";
        }
        else {
            print "\t'$pod' todavía no existe\n";
        }
    }
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

pod2es es el proyecto de traducción al español de la documentación básica de
Perl. Por su dimensión, es un proyecto a largo plazo.

Vea L<http://github.com/zipf/perldoc-es> para obtener más información.

Cuando haya instalado el paquete, puede utilizar el siguiente comando para
consultar la documentación:

  %> perldoc POD2::ES::<nombre_de_pod>

=head1 ACTUALIZACIÓN DE perldoc

Por desgracia, los útiles modificadores C<-f> y C<-q> de C<perldoc> no
funcionan con la documentación traducida.

Por esta razón, a partir de la versión 3.14 de Pod::Perldoc se permite utilizar
la siguiente sintaxis:

  %> perldoc -L ES <nombre_pod>
  %> perldoc -L ES -f <función>
  %> perldoc -L ES -q <expresión regular P+F>

El modificador C<-L> permite definir el código de idioma para la traducción
deseada. Si el paquete C<POD2::E<lt>idiomaE<gt>> no existe, no se aplicará el
modificador.

Los más perezosos pueden agregar un alias del sistema:

  perldoc-es="perldoc -L ES "

para no tener que escribir el modificador C<-L> cada vez:

  %> perldoc-es -f map 
 
Con la versión 3.15 de Pod::Perldoc se puede usar la variable de entorno
PERLDOC_POD2. Si se establece esta variable en '1', perldoc buscará en la
documentación pod según el idioma indicado en las variables LC_ALL, LC_LANG o
LANG. O bien, se puede establecer en el valor 'es', con lo que buscará
directamente en la documentación en español. Por ejemplo:

       export PERLDOC_POD2="es"
       perldoc perl


Tenga en cuenta que la revisión es para la versión 3.14 de
L<Pod::Perldoc|Pod::Perldoc> (incluida en Perl 5.8.7 y en Perl 5.8.8). Si tiene
una distribución de Perl anterior (salvo la E<gt>= 5.8.1) y está impaciente por
aplicar la revisión, actualice el módulo L<Pod::Perldoc|Pod::Perldoc> a la
versión 3.14. Perl 5.10 ya contiene esta funcionalidad, por lo que no es
necesario aplicar la revisión.

Consulte la API C<search_perlfunc_re> para obtener más información.


=head1 API

El paquete exporta las siguientes funciones:

=over 4

=item * C<new>

Se ha agregado por compatibilidad con la función C<perldoc> de Perl 5.10.1.
L<Pod::Perldoc> la utiliza para devolver el nombre del paquete de traducción.

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

Como el método C<search_perlfunc> de F<Pod/Perldoc.pm> utiliza la cadena "Lista
de funciones de Perl en orden alfabético" incluida en el código (como una
expresión regular) para omitir la introducción, a fin de que el archivo de
revisión funcione con otros idiomas con la opción C<-L>, hemos utilizado un
mecanismo sencillo, similar a un complemento.

El paquete de idioma C<POD2::E<lt>idiomaE<gt>> debe exportar
C<search_perlfunc_re> para devolver una traducción de la cadena mencionada en
el párrafo anterior. Esta cadena se usará para omitir la introducción de
F<perlfunc.pod>. Si C<POD2::E<lt>idiomaE<gt>-E<gt>search_perlfunc_re> genera un
error (o no existe), se restablece el comportamiento predeterminado. Este
mecanismo permite agregar traducciones de C<POD2::*> adicionales sin necesidad
de aplicar cada vez la revisión de F<Pod/Perldoc.pm>.

=back

=head1 PROYECTO

Encontrará más información sobre el proyecto en
L<http://github.com/zipf/perldoc-es>.

=head1 AUTORES

=over

=item * Joaquín Ferrero (Tech Lead), C< explorer + POD2ES at joaquinferrero.com >

=item * Enrique Nell (Language Lead), C< blas.gordon + POD2ES at gmail.com >

=back

=head1 NOTAS SOBRE LA TRADUCCIÓN

Para este proyecto hemos tomado las siguientes decisiones:

=over

=item * No utilizar caracteres acentuados en los nombres de variables y
funciones de los ejemplos de código

Es perfectamente posible utilizarlos (solo hay que codificar el programa como
UTF-8 y agregar "use utf8;" al principio), pero teniendo en mente a ese
programador más impulsivo, que valora su tiempo y no quiere perderse en
reflexiones ni verse encorsetado por las normas de la lengua, creemos que así
resultará más fácil probar el código de los ejemplos.

Por otra parte, en aquellos sistemas que cuenten con un sistema antiguo de
visualización de texto, como los terminales de línea de comandos, es posible
que se pierdan los acentos. En la mayor parte de los casos será debido a la
presencia de una versión de groff (programa utilizado por los comandos man y
perldoc) que no admite dichos caracteres. En la documentación HTML no debería
haber problemas.


=item * No traducir los términos "array" y "hash"

Si tenemos en cuenta que Perl tiene más de 20 años y que la inmensa mayoría de
los libros disponibles sobre este lenguaje están en inglés, a nadie extrañará
que la comunidad de habla hispana se refiera a estos tipos de datos por su
nombre en inglés. Existen posibles traducciones, como "matriz", "lista" o
"arreglo" para "array", o "diccionario" para "hash", pero su uso no se ha
extendido, por lo que hemos preferido utilizar su nombre original. Creemos que
esto facilitará la lectura de la documentación.


=item * Utilizar "español neutro"

El "español neutro" es un español controlado que pretende evitar el uso de
términos ofensivos o de construcciones poco frecuentes en determinados países
de habla hispana, con el objetivo de lograr traducciones válidas para España y
Latinoamérica.

=back


=head1 VEA TAMBIÉN

L<POD2::PT_BR>, L<POD2::IT>, L<POD2::FR>, L<POD2::LT>, L<perl>.


=head1 ERRORES

Puede notificar errores (bugs) o solicitar funcionalidad a través de la
dirección de correo electrónico C<bug-pod2-esd at rt.cpan.org> o de la interfaz
web en L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POD2-ES>. Se le
comunicarán automáticamente los cambios relacionados con los errores
notificados o la funcionalidad solicitada.


=head1 SOPORTE

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

Los autores desean expresar su gratitud al equipo de desarrollo de OmegaT, la
herramienta utilizada para la traducción.


=head1 REFERENCIAS

Proyecto OmegaT: L<http://omegat.org/>


=head1 DONATIVOS

Por el elevado volumen de trabajo que representa y su larga duración, el
proyecto de traducción de la documentación de Perl requiere un esfuerzo
sostenido que sólo está al alcance de los espíritus más sólidos y altruistas.
Los autores no exigen--pero tampoco rechazarán--compensaciones en forma de
dinero, libros, quesos y productos derivados del cerdo (o chancho), o incluso
viajes a la Polinesia, destinadas a reducir la fatiga del equipo y a mantener
alta la moral. Todo será bienvenido.


=head1 LICENCIA Y COPYRIGHT

Copyright 2011 Equipo de Perl en Español.

Este programa es software libre; puede redistribuirlo o modificarlo bajo los
términos de la licencia GNU General Public License publicada por la Free
Software Foundation, o los de la licencia Artistic.

Consulte http://dev.perl.org/licenses/ para obtener más información.


=cut
