#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell

use strict;
use warnings;
use File::Copy;
use File::Basename;
use Text::Wrap qw(wrap $columns);
use utf8;

$|++;

my $pod_path;

if ( $ARGV[0] ) {

    $pod_path = $ARGV[0];

} else {
 
    die "Usage: perl preprocessing.pl <pod_path>\n";

}


my ($in_path, $out_path);
$in_path = "$pod_path.bak";
$out_path = $pod_path;

copy($pod_path, $in_path);


open my $in, '<:encoding(latin-1)', $in_path;
open my $out, '>:encoding(latin-1)', $out_path;

# wrap lines (OmegaT removes some line breaks) 

$columns = 76;

while ( <$in> ) {

    if ( /^\s*$/ ) {
        print $out $_;
        next;
    }
      
    print $out wrap( "", "", ("$_") );

}

close $in;

# Add TRANSLATORS section

print $out "\n\n=head1 TRADUCTORES\n\n";
print $out "=over\n\n";
print $out "=item * Joaquín Ferrero, C< explorer at joaquinferrero.com >\n\n";
print $out "=item * Enrique Nell, C< blas.gordon at gmail.com >\n\n";
print $out "=back";

close $out;


# Convert pod to html for visual check

my ($name, $path, $suffix) = fileparse($pod_path, qr{\.pod;\.pm});
my $out_html = $path . "/$name.html";

system("perl -MPod::Simple::HTML -e Pod::Simple::HTML::go $pod_path > $out_html");




