#!/usr/bin/perl
use common::sense;
use File::Copy;

my $dir          = '/home/explorer/Documentos/Desarrollo';
my $dir_omegat   = "$dir/perlspanish";
my $dir_proyecto = "$dir/perldoc-es";
my $dir_destino  = "$dir_proyecto/pod/reviewed";
my $dir_origen   = "$dir_omegat/target";

my $listado      = "$dir_proyecto/pod_traducidos.txt";

open my $fh, q[<], $listado  or  die "ERROR: [$listado]: $!\n";

while (<$fh>) {

    chomp;
    
    copy("$dir_origen/$_", $dir_destino);
    
    say "[$dir_origen/$_]=>[$dir_destino/$_]";
}

close $fh;
