#!/usr/bin/env perl

# Copyright 2011-2012 by Enrique Nell
#
# Requires Pod::Simple::HTML

use 5.012;
use warnings;
use File::Copy;
use File::Basename;
use Readonly;
use Pod::Tidy qw( tidy_files );
use Getopt::Long;
#use Encode;
#use utf8;

$|++;

my (@names, $translator);

my $result = GetOptions(
                        "pod=s"   => \@names,
                        "trans=s" => \$translator,
                       );


#if ( $ARGV[0] ) {

#    while (@ARGV) {
#        my $name = shift @ARGV;
#        push @names, $name;
#    }

#} else {
# 
#    die "Usage: perl postprocess.pl <pod_name1> <pod_name2> ... # e.g., perldata.pod\n";
#
#}


# Hard-coded paths relative to /perldoc-es/tools
# Source
Readonly my $SOURCE_PATH => "../../omegat_516/516/source";
Readonly my $TRANS_PATH  => "../../omegat_516/516/target";
Readonly my $MEM_PATH    => "../../omegat_516/516/omegat/project_save.tmx";   
# Target
Readonly my $CLEAN_PATH  => "../../omegat_clean_prj/source";
Readonly my $DISTR_PATH  => "../POD2-ES/lib/POD2/ES";
Readonly my $POD_PATH    => "../pod/reviewed";
Readonly my $CLEANM_PATH => "../../omegat_clean_prj/omegat/project_save.tmx";

# read team from __DATA__ section
my %team;

while ( <DATA> ) {
    chomp;

    next if '';

    my ($alias, $details) = split /,/;
   
    #$alias   = encode("iso-8859-1", $alias);
    #$details = encode("iso-8859-1", $details);

    say $alias;
    say $details;

    $team{$alias} = $details;

}


foreach my $pod_name (@names) {

    my $source = "$SOURCE_PATH/$pod_name";
    my $trans  = "$TRANS_PATH/$pod_name";
    my $pod    = "$POD_PATH/$pod_name";
    my $clean  = "$CLEAN_PATH/$pod_name";

    # Get path components
    my ($name, $path, $suffix) = fileparse($trans, qr{\.pod|\.pm|\..*});    
    say $name;
    say $path;
    say $suffix;

    my ( $ext ) = $suffix =~ /\.(.+)$/;

    my ( $readme, $final_name );
    if ( $name eq "README" ) {
        
        $readme++;
        say "Readme file" if $readme;

        $final_name = "perl$ext.pod"; # new name convention for READMEs in 5.16

    } else {
        
        $final_name = $pod_name;

    }
    
    my $distr  = "$DISTR_PATH/$final_name";

    # copy work memory to clean project => clean memory
    copy($MEM_PATH, $CLEANM_PATH);

    # copy source file to clean project => clean memory
    copy($source, $clean);
        
    # copy generated file to github archive (won't go through postprocessing)
    copy($trans, $pod);

    # copy generated file to distribution
    copy($trans, $distr);

    

    # Replace double-spaces after full-stop with single space
    open my $dirty, '<:encoding(latin-1)', $distr;
   
    my $text = do { local $/; <$dirty> };
    
    close $dirty;

    $text =~ s/(?<=\.)  (?=[A-Z])/ /g; # two white spaces after full stop

    # Check if there is a =encoding utf8 command
    my $utf8;
    $utf8++ if $text =~ /^=encoding utf8/;
    
    say "UTF-8-encoded file";

    my $encoding;
    if ( $utf8 ) {
        $encoding = "UTF-8";
    } else {
        $encoding = "latin-1";
    }

    open my $fixed, ">:encoding($encoding)", $distr;
    
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
        open my $dirty, "<:encoding($encoding)", $distr;
   
        my $text = do { local $/; <$dirty> };
    
        close $dirty;

        $text =~ s/^=head1 FOO\n\n//;

        open my $fixed, ">:encoding($encoding)", $distr;

        print $fixed $text;

        close $fixed;
    }


    # Add TRANSLATORS section to distribution file
    open my $out, ">>:encoding($encoding)", $distr;

    my $translators_section =  "\n=head1 TRADUCTORES\n\n=over\n\n";
    
    my @file_team = ("explorer", "zipf"); # default team

    unshift(@file_team, $translator) if $translator;
    
    $translators_section .= "=item * $team{$_}\n\n" foreach @file_team;
    $translators_section .= "=back\n\n";
    
    print $out $translators_section;
    
    close $out;
    

    # Generate HTML file for proofreading;
    my $html = "$POD_PATH/$name$suffix.html";
    system("perl -MPod::Simple::HTML -e Pod::Simple::HTML::go $distr > $html");

    unlink "$distr~";

}

__DATA__
j3nnn1,Jennifer Maldonado, C< jcmm986 + POD2ES at gmail.com >
mgomez,Manuel Gómez Olmedo, C< mgomez + POD2ES at decsai.ugr.es >
explorer,Joaquín Ferrero (Tech Lead), C< explorer + POD2ES at joaquinferrero.com >
zipf,Enrique Nell (Language Lead), C< blas.gordon + POD2ES at gmail.com >   
