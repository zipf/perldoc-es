#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell
# 
# Merge clean memory (i.e., reviewed segments) into work memory, 
# overwriting matching work segments

use strict;
use warnings;
use 5.012;
use Readonly;
use XML::Twig;


# Hard-coded paths relative to /perldoc-es/tools
# Clean memory
Readonly my $CLEAN_PATH  => '../tm/clean/omegat_clean_prj-omegat.tmx';
# Work memory
Readonly my $WORK_PATH   => '../tm/work/perlspanish-omegat.explorer.tmx';
# Merged memory
Readonly my $MERGED_PATH => '../tm/work/current_work_memory.tmx';


# Read clean memory and fill %clean hash
my $clean_href = read_tmx($CLEAN_PATH);

my $clean_entries = scalar(keys %{$clean_href});
say "$clean_entries entries in clean memory";


# Process work memory entries, to get non-matching entries 
# and determine number of duplicates

my @non_matching; 
my $duplicates = 0;

my $twig = XML::Twig->new( 
                           keep_atts_order => 1, 
                           twig_handlers => { tu => sub { merged_tu(@_, $clean_href, \@non_matching, \$duplicates) } } 
                          );

$twig->parsefile($WORK_PATH);

$twig->purge();

say "Duplicates: $duplicates";
say "Non-duplicate work memory entries that will be added to merged memory: " . scalar @non_matching;


# Open merged memory and insert non-duplicate entries
my $twig_merged = XML::Twig->new( keep_atts_order => 1, pretty_print => 'indented' );

$twig_merged->parsefile($CLEAN_PATH);

my $body = $twig_merged->first_elt('body');
#my $root = $twig_merged->set_root($body);

my $added;
foreach my $entry (@non_matching) {
    
    $added++;
    $entry->paste( last_child => $body );
}

open my $out, '>', $MERGED_PATH;

$twig_merged->print($out);
$twig_merged->purge();

say "Total entries in merged memory: ", $clean_entries + $added;


sub merged_tu {

    my ($t, $elt, $clean_href, $non_matching_aref, $duplicates) = @_;
    
    my $source = ( $elt->children() )[0]->text();
    
    if ($clean_href->{$source}) {
        
        $$duplicates++;

    } else {

        push @{$non_matching_aref}, $elt;

    }

    $elt->purge();

}


sub read_tmx {

    my $path = shift;

    my %segments;
    
    # Define twig object, creating closure in handler to pass additional \%segments argument
    my $twig = XML::Twig->new( 
                               keep_atts_order => 1, 
                               twig_handlers => { tu => sub { process_unit( @_, \%segments ) } } 
                             );

    $twig->parsefile($path);
    $twig->purge();

    return \%segments;

}


sub process_unit {

    my ($t, $elt, $segments_href) = @_;
 
    my $source = ( $elt->children() )[0]->text();
    $segments_href->{ $source } =  $elt;

    $elt->purge();

}


