#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell

use strict;
use warnings;
use File::Copy;
use Text::Wrap qw(wrap $columns);
use utf8;
use 5.012;

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

$columns = 76;

while ( <$in> ) {

    if ( /^\s*$/ ) {
        print $out $_;
        next;
    }
      
    print $out wrap( "", "", ("$_") );

}

close $in;

print $out "\n\n=head1 TRADUCTORES\n\n";
say $out "Joaquín Ferrero C<< explorer at joaquinferrero.com >>";
say $out "Enrique Nell C<< blas.gordon at gmail.com >>";

close $out;

