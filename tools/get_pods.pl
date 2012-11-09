#!/usr/bin/env perl
#
# Copy files from Perl distribution to source/ directory in OmegaT project.
#
use v5.12;
use autodie;
use File::Copy;

### Configuration ###
my $SOURCE_DIR = '/home/explorer/perl5/perlbrew/build/perl-5.16.2';	# Distribution directory
my $TARGET_DIR = '/home/explorer/perlspanish/source';			# source/ OmegaT directory
my @EXCEPTIONS = qw(
    README.cn
    README.ko
    README.jp
    README.tw
    perltoc.pod
);
#####################

### Vars ###
my $number_files = 0;
#####################

### Check ###
if (not -d $TARGET_DIR) {		# Create destination dir.
    mkdir $TARGET_DIR;
}
if (<$TARGET_DIR/*>) {			# Check dirs.
    die "ERROR: $TARGET_DIR contains files! I need a clean bedroom.\n";
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

### Copy READMEs
{
    opendir my $DIR, $SOURCE_DIR;
    while (my $file = readdir $DIR) {
	next if $file !~ /^README/;
	copy_file($SOURCE_DIR, $file);
    }
    closedir $DIR;
}

### Copy pods
{
    my $source_dir = "$SOURCE_DIR/pod";
    opendir my $DIR, $source_dir;
    while(my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if -l $source_file;		# No symlinks
	next if $source_file !~ /[.]pod$/;
	copy_file($source_dir, $file);
    }
    closedir $DIR;
}

### Copy faqs & additional pods
{
    my $source_dir = "$SOURCE_DIR/lib";
    opendir my $DIR, $source_dir;
    while (my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if $file !~ /^perl.+\.pod$/;
	copy_file($source_dir, $file);
    }
    closedir $DIR;
}

### End
say "Files copied: $number_files";

### Subroutines
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
