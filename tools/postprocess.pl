#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell
#
# Requires Pod::Simple::HTML

use strict;
use warnings;
use 5.012;
use File::Copy;
use File::Basename;
use Readonly;
use Pod::Tidy qw( tidy_files );
use utf8;

my @names;

if ( $ARGV[0] ) {

    while (@ARGV) {
        my $name = shift @ARGV;
        push @names, $name;
    }

} else {
 
    die "Usage: perl copy_files.pl <pod_name> # e.g., perldata.pod\n";

}


# Hard-coded paths relative to /perldoc-es/tools
# Source
Readonly my $SOURCE_PATH    => "../../omegat_514/514/source";
Readonly my $TRANS_PATH    => "../../omegat_514/514/target";
# Target
Readonly my $CLEAN_PATH  => "../../omegat_clean_prj/source";
Readonly my $DISTR_PATH  => "../POD2-ES/5.14.1/POD2-ES/lib/POD2/ES";
Readonly my $POD_PATH    => "../pod/5.14.1/reviewed";

# Translators section for POD
Readonly my $TRANSLATORS_POD => <<'END';

=head1 TRADUCTORES

=over

=item * Joaquín Ferrero (Tech Lead), C< explorer + POD2ES at joaquinferrero.com >

=item * Enrique Nell (Language Lead), C< blas.gordon + POD2ES at gmail.com >

=back

END



foreach my $pod_name (@names) {

    my $source = "$SOURCE_PATH/$pod_name";
    my $trans  = "$TRANS_PATH/$pod_name";
    my $distr  = "$DISTR_PATH/$pod_name";
    my $pod    = "$POD_PATH/$pod_name";
    my $clean  = "$CLEAN_PATH/$pod_name";

    # copy source file to clean project => clean memory
    copy($source, $clean);
        
    # copy generated file to github archive (won't go through postprocessing)
    copy($trans, $pod);

    # copy generated file to distribution
    copy($trans, $distr);

    
    # Post-processing stage
    
    # Replace double-spaces after full-stop with single space

    open my $dirty, '<:encoding(latin-1)', $distr;

    my $text = do { local $/; <$dirty> };

    close $dirty;


    $text =~ s/(?<=\.)\s\s(?=[A-Z])/ /gs;


    open my $fixed, '>:encoding(latin-1)', $distr;

    print $fixed $text;

    close $fixed;

        
    # Wrap lines (OmegaT removes some line breaks) using Pod::Tidy 
    my $processed = Pod::Tidy::tidy_files(
                                            files   => [ $distr ],
                                            inplace => 1,
                                            columns => 80,
                                         );
    
    # Add TRANSLATORS section to distribution file
    open my $out, '>>:encoding(latin-1)', $distr;

    print $out $TRANSLATORS_POD;
    
    close $out;
    
    # Get path components
    my ($name, $path, $suffix) = fileparse($trans, qr{\.pod|\.pm});

    # generate HTML file for proofreading;
    my $html = "$POD_PATH/$name.html";
    system("perl -MPod::Simple::HTML -e Pod::Simple::HTML::go $distr > $html");

    unlink "$distr~";

}
