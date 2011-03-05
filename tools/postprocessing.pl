#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell
#
# Requires Pod::Simple::HTML

use strict;
use warnings;
use File::Copy;
use File::Basename;
use Pod::Tidy qw( tidy_files );
use utf8;

$|++;

my $pod_path;

if ( $ARGV[0] ) {

    $pod_path = $ARGV[0];

} else {
 
    die "Usage: perl preprocessing.pl <pod_path>\n";

}


# Wrap lines (OmegaT removes some line breaks) 

my $processed = Pod::Tidy::tidy_files(
                                        files   => [ $pod_path ],
                                        inplace => 1,
                                        columns => 80,
                                     );


# Get path components

my ($name, $path, $suffix) = fileparse($pod_path, qr{\.pod;\.pm});


# Add TRANSLATORS section

open my $out, '>>:encoding(latin-1)', $pod_path;

if ( $suffix =~ /\.pod|\.pm/ ) {

    print $out  <<'END';

=head1 TRADUCTORES

=over

=item * Joaquín Ferrero, C< explorer + POD2ES at joaquinferrero.com >

=item * Enrique Nell, C< blas.gordon + POD2ES at gmail.com >

=back

END

} else {   # e.g., README files


    print $out  <<'END';

TRADUCTORES

Joaquín Ferrero, explorer + POD2ES at joaquinferrero.com

Enrique Nell, C< blas.gordon + POD2ES at gmail.com

END

}

close $out;



# Convert pod to html for visual check

my $out_html = $path . "/$name.html";

system("perl -MPod::Simple::HTML -e Pod::Simple::HTML::go $pod_path > $out_html");




