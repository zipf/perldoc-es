#!/usr/bin/env perl
#
# PerlSpanish
#
# Init OmegaT source/ directory and files list file
#
# · copy files from Perl distribution to source/ directory in OmegaT project
# · update files list file
#
# 2015/05/17 - basado en get_pods.pl
#
use v5.18.2;
use autodie;
use File::Copy;

### Configuration -------------------------------------------------------------
my $user	  = 'explorer';
my $version	  = '5.22.0';
my $DEBUG         = 0;							# 0 .. 2
my $PERL_DIST_DIR = "/home/$user/perl5/perlbrew/build/perl-$version";
my $PROJECT_DIR   = "/home/$user/Documentos/Desarrollo/perlspanish-$version";
### End configuration ---------------------------------------------------------


### Constant ------------------------------------------------------------------
my $PROJECT_SOURCE_DIR = "$PROJECT_DIR/source";
my $FILES_LST_FILE     = 'files.lst';
my @EXCEPTIONS = qw(
    README.cn
    README.ko
    README.jp
    README.tw
    perltoc.pod
);


### Variables -----------------------------------------------------------------
my $number_files = 0;					# file counter


### Check ---------------------------------------------------------------------
-d $PERL_DIST_DIR      or die "ERROR: the source distribution directory does not exist: $! [$PERL_DIST_DIR]\n";
-d $PROJECT_DIR        or die "ERROR: couldn't find the OmegaT project directory: $! [$PROJECT_DIR]\n";
-d $PROJECT_SOURCE_DIR or mkdir $PROJECT_SOURCE_DIR or die "ERROR: can't found [source/] directory: $!\n";

if (<$PROJECT_SOURCE_DIR/*>) {
    die "ERROR: [$PROJECT_SOURCE_DIR] have previous files! I need a clean bedroom.\n";
}
if (not -e "$PERL_DIST_DIR/README") {
    die "ERROR: Couldn't find the README file in [$PERL_DIST_DIR] directory.\n";
}
if (not -d "$PERL_DIST_DIR/pod") {
    die "ERROR: Couldn't find the [pod/] directory in [$PERL_DIST_DIR]\n";
}


### Read description ----------------------------------------------------------
my %toc;
{
    open my $TOC, '<', "$PERL_DIST_DIR/pod/perltoc.pod";
    while (<$TOC>) {
	next unless /^=head2 (.+? )?(?<file>perl\w*) -+ (?<desc>.+)/;
	my($file,$desc) = @+{'file', 'desc'};
	my $next_line = <$TOC>;
	$next_line =~ s/^\s+|\s+$//g;
	$toc{ $file } = join " ", $desc, $next_line;
    }
    close $TOC;

    say scalar(keys %toc), " files found in perltoc" if $DEBUG;
}


### Copy READMEs files --------------------------------------------------------
my @files_lst;
{
    opendir my $DIR, $PERL_DIST_DIR;

    while (my $file = readdir $DIR) {
	next if $file !~ /^README/;
	say $file if $DEBUG > 1;

	# COPY
	copy_file($PERL_DIST_DIR, $file);

	# UPDATE FILES LIST
	my($suffix) = $file =~ /README\.(\w+)/;

	my $tabs = tabs($file);

	if (!$suffix) {					# 'README'
	    push @files_lst, "$file${tabs}About Perl";
	}
	else {						# 'README.'
	    if (!$toc{"perl$suffix"}) {			# don't have description (not exist in perltoc.pod)

		if ($suffix eq 'micro') {		# 'README.micro'
		    push @files_lst, $file . $tabs . "microperl is supposed to be a really minimal perl";
		}
		else {
		    print "ERROR: $suffix don't have description\n";
		    push @files_lst, $file;
		}
	    }
	    else {
		if ($suffix eq 'vms') {			# 'README.vms'
		    push @files_lst, $file . $tabs . "Configuring, building, testing, and installing perl on VMS";
		}
		else {
		    push @files_lst, $file . $tabs . $toc{"perl$suffix"};
		}
	    }
	}
    }

    closedir $DIR;
}


### Copy pods -----------------------------------------------------------------
{
    my $source_dir = "$PERL_DIST_DIR/pod";

    opendir my $DIR, $source_dir;

    while(my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if -l $source_file;				# Don't like symlinks!
	next if    $source_file !~ /[.]pod$/;			# Only pods!

	copy_file($source_dir, $file);

	update_files_list($file);
    }
    closedir $DIR;
}


### Copy faqs & additional pods -----------------------------------------------
{
    my $source_dir = "$PERL_DIST_DIR/lib";

    opendir my $DIR, $source_dir;

    while (my $file = readdir $DIR) {
	my $source_file = "$source_dir/$file";
	next if $file !~ /^perl.+\.pod$/;

	copy_file($source_dir, $file);

	update_files_list($file);
    }

    closedir $DIR;
}

### Open files list file ------------------------------------------------------
open my $LST, '>', "$PROJECT_DIR/$FILES_LST_FILE";
for my $files_lst (sort @files_lst) {
    say $LST $files_lst;
}
close $LST;
say "Number of files copied: $number_files"			if $DEBUG;



### Subroutines ---------------------------------------------------------------
sub copy_file () {
    my($source_dir, $file) = @_;
    next if grep { $_ eq $file } @EXCEPTIONS;

    my $source_file = "$source_dir/$file";
    my($atime, $mtime) = (stat($source_file))[8,9];
    copy($source_file, $PROJECT_SOURCE_DIR);
    utime $atime, $mtime, "$PROJECT_SOURCE_DIR/$file";

    $number_files++;
}

sub update_files_list() {
    my $file = shift;
    my($perlfile) = $file =~ /(.+?)\.pod/;

    if (!$toc{$perlfile}) {
	print "ERROR: $file don't have description\n";
	push @files_lst, $file;
    }
    else {
	push @files_lst, $file . tabs($file) . $toc{$perlfile};
    }
}

sub tabs() {
    my $file = shift;
    "\t" x (3 - int(length($file) / 8));
}

__END__
