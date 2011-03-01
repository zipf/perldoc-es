#!/usr/bin/perl
use strict;
use warnings;
use open OUT => ':locale';

use POD2::ES;

my $pod_es = POD2::ES->new();

print "Directorios de instalación:\n";
print "\t", join("\n\t", $pod_es->pod_dirs());
print "\n\n";

print "Titular de la lista alfabética de funciones Perl:\n";
my $texto = $pod_es->search_perlfunc_re();
print "\t", $texto;
print "\n\n";

print "Lista de pods traducidos:\n";
$pod_es->print_pods();
print "\n";

print "Estado de perlintro:\n";
$pod_es->print_pod('perlintro');
print "\n\n";

