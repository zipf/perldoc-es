#!/usr/bin/env perl

# Copyright 2011 by Enrique Nell
#
# Requires Pod::Simple::HTML

use 5.012;
use warnings;
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
 
    die "Usage: perl postprocess.pl <pod_name1> <pod_name2> ... # e.g., perldata.pod\n";

}


# Hard-coded paths relative to /perldoc-es/tools
# Source
Readonly my $SOURCE_PATH => "../../omegat_514/514/source";
Readonly my $TRANS_PATH  => "../../omegat_514/514/target";
Readonly my $MEM_PATH    => "../../omegat_514/514/omegat/project_save.tmx";   
# Target
Readonly my $CLEAN_PATH  => "../../omegat_clean_prj/source";
Readonly my $DISTR_PATH  => "../POD2-ES/lib/POD2/ES";
Readonly my $POD_PATH    => "../pod/reviewed";
Readonly my $CLEANM_PATH => "../../omegat_clean_prj/omegat/project_save.tmx";

# Translators section for POD
Readonly my $TRANSLATORS_POD => <<'END';

=head1 TRADUCTORES

=over

=item * Joaquí­n Ferrero (Tech Lead), C< explorer + POD2ES at joaquinferrero.com >

=item * Enrique Nell (Language Lead), C< blas.gordon + POD2ES at gmail.com >

=back

END



foreach my $pod_name (@names) {

    my $source = "$SOURCE_PATH/$pod_name";
    my $trans  = "$TRANS_PATH/$pod_name";
    my $distr  = "$DISTR_PATH/$pod_name";
    my $pod    = "$POD_PATH/$pod_name";
    my $clean  = "$CLEAN_PATH/$pod_name";

    # copy work memory to clean project => clean memory
    copy($MEM_PATH, $CLEANM_PATH);

    # copy source file to clean project => clean memory
    copy($source, $clean);
        
    # copy generated file to github archive (won't go through postprocessing)
    copy($trans, $pod);

    # copy generated file to distribution
    copy($trans, $distr);

    
    # Post-processing stage
    
    # Get path components
    my ($name, $path, $suffix) = fileparse($trans, qr{\.pod|\.pm|\..*});    
    say $name;
    say $path;
    say $suffix;

    my $readme;
    $readme++ if $name eq "README";
    say "Readme file" if $readme;    

    # Replace double-spaces after full-stop with single space
    open my $dirty, '<:encoding(latin-1)', $distr;
   
    my $text = do { local $/; <$dirty> };
    
    close $dirty;

    $text =~ s/(?<=\.)  (?=[A-Z])/ /g; # two white spaces after full stop

    open my $fixed, '>:encoding(latin-1)', $distr;
    
    if ($readme) {
     
        # Add pod formatting to the first paragraph, to help Pod::Tidy 
        print $fixed "=head1 FOO\n\n$text";

    } else {

        print $fixed $text;

    }

    close $fixed;


    # Wrap lines (OmegaT removes some line breaks) using Pod::Tidy 
    my $processed = Pod::Tidy::tidy_files(
                                            files   => [ $distr ],
                                            inplace => 1,
                                            columns => 80,
                                         );


    if ($readme) {
        
        # Remove added pod formatting from README files 
        open my $dirty, '<:encoding(latin-1)', $distr;
   
        my $text = do { local $/; <$dirty> };
    
        close $dirty;

        $text =~ s/^=head1 FOO\n\n//;

        open my $fixed, '>:encoding(latin-1)', $distr;

        print $fixed $text;

        close $fixed;
    }


    # Add TRANSLATORS section to distribution file
    open my $out, '>>:encoding(latin-1)', $distr;

    print $out $TRANSLATORS_POD;
    
    close $out;
    

    # Generate HTML file for proofreading;
    my $html = "$POD_PATH/$name$suffix.html";
    system("perl -MPod::Simple::HTML -e Pod::Simple::HTML::go $distr > $html");

    unlink "$distr~";

}
