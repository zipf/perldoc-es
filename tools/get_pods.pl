#!/usr/bin/env perl
#
# Copy files from Perl distribution to source/ directory in OmegaT project.
# Update pod.lst file (files and descriptions).
#
use v5.12;
use autodie;
use File::Copy;


### Configuration -------------------------------------------------------------
my $SOURCE_DIR = '/home/explorer/perl5/perlbrew/build/perl-5.20.0';	# Distribution directory
my $TARGET_DIR = '/home/explorer/Proyectos/perlspanish/source';		# source/ OmegaT directory
my @EXCEPTIONS = qw(
    README.cn
    README.ko
    README.jp
    README.tw
    perltoc.pod
);

### ---------------------------------------------------------------------------


### Vars ----------------------------------------------------------------------
my $number_files = 0;

### ---------------------------------------------------------------------------


### Check ---------------------------------------------------------------------
if (not -d $TARGET_DIR) {		# Create destination dir.
    mkdir $TARGET_DIR;
}
if (<$TARGET_DIR/*>) {			# Check dirs.
#    die "ERROR: $TARGET_DIR contains files! I need a clean bedroom.\n";
}

if (not -d $SOURCE_DIR) {
    die "ERROR: The source distribution directory does not exist.\n";
}

if (not -e "$SOURCE_DIR/README") {
    die "ERROR: Couldn't find the README file in $SOURCE_DIR directory.\n";
}

if (not -d "$SOURCE_DIR/pod") {
    die "ERROR: Couldn't find the pod/ directory in $SOURCE_DIR directory.\n";
}


### Read description ----------------------------------------------------------
open my $TOC, '<', "$SOURCE_DIR/pod/perltoc.pod";

my %toc;

while (<$TOC>) {
    next unless /^=head2 (.+? )?(?<file>perl\w*) -+ (?<desc>.+)/;
    
    $toc{ $+{file} } = $+{desc};
}

close $TOC;


### Open for pod.lst ----------------------------------------------------------
open my $LST, '>', "$TARGET_DIR/../pod.lst";


### Copy READMEs --------------------------------------------------------------
{
    opendir my $DIR, $SOURCE_DIR;
    while (my $file = readdir $DIR) {
	next if $file !~ /^README/;
	copy_file($SOURCE_DIR, $file);

	my($suffix) = $file =~ /README\.(\w+)/;
	
	if (!$suffix) {
	    print $LST "$file\tAbout Perl\n";
        }
        else {
            if (!$toc{"perl$suffix"}) {
                if ($suffix eq 'micro') {
                    print $LST $file . "\t" . "microperl is supposed to be a really minimal perl\n";
                }
                else {
                    print "ERROR: $suffix don't have description\n";
                    print $LST $file . "\n";
                }
            }
            else {
                if ($suffix eq 'vms') {
                    print $LST $file . "\t" . "Configuring, building, testing, and installing perl on VMS\n";
                }
                else {
                    print $LST $file . "\t" . $toc{"perl$suffix"} . "\n";
                }
            }
        }

    }
    closedir $DIR;
}


### Copy pods -----------------------------------------------------------------
{
    my $source_dir = "$SOURCE_DIR/pod";
    opendir my $DIR, $source_dir;
    while(my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if -l $source_file;				# No symlinks!
	next if $source_file !~ /[.]pod$/;
	copy_file($source_dir, $file);

	my($perlfile) = $file =~ /(.+?)\.pod/;

	if (!$toc{$perlfile}) {
	    print "ERROR: $file don't have description\n";
	    print $LST $file . "\n";
	}
	else {
	    print $LST $file . "\t" . $toc{$perlfile} . "\n";
	}
    }
    closedir $DIR;
}

### Copy faqs & additional pods -----------------------------------------------
{
    my $source_dir = "$SOURCE_DIR/lib";
    opendir my $DIR, $source_dir;
    while (my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if $file !~ /^perl.+\.pod$/;
	copy_file($source_dir, $file);

	my($perlfile) = $file =~ /(.+?)\.pod/;

	if (!$toc{$perlfile}) {
	    print "ERROR: $file don't have description\n";
	    print $LST $file . "\n";
	}
	else {
	    print $LST $file . "\t" . $toc{$perlfile} . "\n";
	}

    }
    closedir $DIR;
}


### End -----------------------------------------------------------------------

say "Files copied: $number_files";

close $LST;


### Subroutines ---------------------------------------------------------------
sub copy_file {
    my($source_dir, $file) = @_;

    next if $file ~~ @EXCEPTIONS;

    my $source_file = "$source_dir/$file";
    my($atime, $mtime) = (stat($source_file))[8,9];
    copy($source_file, $TARGET_DIR);
    utime $atime, $mtime, "$TARGET_DIR/$file";

    $number_files++;
}

__END__


