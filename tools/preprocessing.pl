#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell

use strict;
use warnings;
use File::Basename;

$|++;

my $pod_path;

if ( $ARGV[0] ) {

    $pod_path = $ARGV[0];

} else {
 
    die "Usage: perl preprocessing.pl <pod_path>\n";

}

my ( $name, $path, $suffix ) = fileparse( $pod_path, qr{\.pod|\.pm} );


# Replace double-spaces after full-stop with single space

open my $pod, '<:encoding(latin-1)', $pod_path;

my $text = do { local $/; <$pod> };

close $pod;


$text =~ s/(?<=\.)\s\s(?=[A-Z])/ /gs;

my $preproc_dir = "$path/_preprocessed/";
mkdir $preproc_dir unless -d $preproc_dir;

my $out_path = $preproc_dir . $name . $suffix;

open my $fixed_pod, '>:encoding(latin-1)', $out_path;

print $fixed_pod $text;

close $fixed_pod;
