#!/usr/bin/env perl
#
# Check POD2::ES setup
#
use strict;
use warnings;
use open OUT => ':locale';
use feature 'say';

use POD2::ES;

my $pod_es = POD2::ES->new();

say 'Setup directories';
say "\t", join("\n\t", $pod_es->pod_dirs()), "\n";

say 'Title of alphabetic list of Perl functions:';
my $text = $pod_es->search_perlfunc_re();
say "\t$text\n";

say "List of translated pods:";
$pod_es->print_pods();
say '';

say 'perlintro status:';
$pod_es->print_pod('perlintro');
say '';
