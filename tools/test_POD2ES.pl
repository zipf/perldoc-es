#!/usr/bin/env perl
#
# Checl POD2::ES instalation
#
use strict;
use warnings;
use open OUT => ':locale';
use feature 'say';

use POD2::ES;

my $pod_es = POD2::ES->new();

say 'Instalation directories';
say "\t", join("\n\t", $pod_es->pod_dirs()), "\n";

say 'Title of Alphabetic list of Perl functions:';
my $text = $pod_es->search_perlfunc_re();
say "\t$text\n";

say "List of translated pods:";
$pod_es->print_pods();
say '';

say 'Status of perlintro:';
$pod_es->print_pod('perlintro');
say '';
