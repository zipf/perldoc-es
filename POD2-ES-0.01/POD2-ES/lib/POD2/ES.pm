package POD2::ES;

use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use base qw(Exporter);
our @EXPORT = qw(print_pod print_pods search_perlfunc_re new pod_dirs);

use utf8;

my $pods = {
    # perl => '5.12.0',
    # perlbook => '5.12.0',
    # perlcheat => '5.12.0',
    # perldata => '5.12.0',
    # perlfunc => '5.12.0',
    # perlstyle => '5.12.0',
    # perlsyn => '5.12.0',
};

sub new {
    return __PACKAGE__;
}

sub pod_dirs {
    ( my $mod = __PACKAGE__ . '.pm' ) =~ s|::|/|g;
    ( my $dir = $INC{$mod} ) =~ s/\.pm\z//;
    return $dir;
}

sub print_pods {
    print_pod(sort keys %$pods);
}

sub print_pod {
    my @args = @_ ? @_ : @ARGV;

    while (@args) {
        (my $pod = lc(shift @args)) =~ s/\.pod$//;
        if ( exists $pods->{$pod} ) {
            print "\t'$pod' translated from Perl $pods->{$pod}\n";
        }
        else {
            print "\t'$pod' doesn't yet exists\n";
        }
    }
}

sub search_perlfunc_re {
    return 'Listado alfabético de funciones de Perl';
}

1;
__END__

=encoding utf8

=head1 NAME

POD2::ES - Spanish translation of Perl core documentation

=head1 SYNOPSIS

  %> perldoc POD2::ES::<podname>  

  use POD2::ES;
  print_pods();
  print_pod('pod_foo', 'pod_baz', ...); 

  %> perl -MPOD2::ES -e print_pods
  %> perl -MPOD2::ES -e print_pod <podname1> <podname2> ...

=head1 DESCRIPTION

pod2es is the Spanish translation project of core Perl pods. This has been (and
currently still is) a very big work! :-) 

See L<http://github.com/zipf/perldoc-es> for more details about the project. 

Once the package has been installed, the translated documentation can be
accessed with: 

  %> perldoc POD2::ES::<podname>

=head1 EXTENDING perldoc

With the translated pods, unfortunately, the useful C<perldoc>'s C<-f> and C<-q> 
switches don't work no longer.

So, we made a simple patch to F<Pod/Perldoc.pm> 3.14 in order to allow also the
syntax: 

  %> perldoc -L ES <podname>
  %> perldoc -L ES -f <function>
  %> perldoc -L ES -q <FAQregex>

The patch adds the C<-L> switch that allows to define language code for desired
language translation. If C<POD2::E<lt>codeE<gt>> package doesn't exists, the
effect of the switch will be ignored.

If you are particularly lazy you can add a system alias like:

  perldoc-es="perldoc -L ES "

in order to avoid to write the C<-L> switch every time and to type directly:

  %> perldoc-es -f map 
 
You can apply the patch with: 

  %> patch -p0 `/path/to/perl -MPod::Perldoc -e 'print $INC{"Pod/Perldoc.pm"}'` < /path/to/Perldoc.pm-3.14-patch

The patch lives under F<./patches/Perldoc.pm-3.14-patch> shipped in this
distribution.

Note that the patch is for version 3.14 of L<Pod::Perldoc|Pod::Perldoc>
(included into Perl 5.8.7 and Perl 5.8.8). If you have a previous Perl distro
(but E<gt>= 5.8.1) and you are impatient to apply the patch, please upgrade
your L<Pod::Perldoc|Pod::Perldoc> module to 3.14! ;-) 

See C<search_perlfunc_re> API for more information.

I<Note: Perl 5.10 already contains this functionality, so you don't have to apply any patch.>

=head1 API

The package exports following functions:

=over 4

=item * C<new>

Added for compatibilty with Perl 5.10.1's C<perldoc>.
Used by L<Pod::Perldoc> in order to return translation package name.

=item * C<pod_dirs>

Added for compatibilty with Perl 5.10.1's C<perldoc>.
Used by L<Pod::Perldoc> in order to find out where to look for translated pods.

=item * C<print_pods>

Prints all translated pods and relative Perl original version.

=item * C<print_pod>

Prints relative Perl original version of all pods passed as arguments.

=item * C<search_perlfunc_re>

Since F<Pod/Perldoc.pm>'s C<search_perlfunc> method uses hard coded string
"Alphabetical Listing of Perl Functions" (as regexp) to skip introduction, in
order to make the patch to work with other languages with the option C<-L>,we
used a simple plugin-like mechanism. 

C<POD2::E<lt>codeE<gt>> language package must export C<search_perlfunc_re> that
returns a localized translation of the paragraph string above. This string will
be used to skip F<perlfunc.pod> intro. Again, if
C<POD2::E<lt>codeE<gt>-E<gt>search_perlfunc_re> fails (or doesn't exist), we'll
come back to the default behavoiur. This mechanism allows to add additional
C<POD2::*> translations without need to patch F<Pod/Perldoc.pm> every time.

=back

=head1 Datos sobre el proyecto

Visite L<http://github.com/zipf/perldoc-es> para obtener más información.

=head1 AUTHORS

POD2::ES package is currently maintained by Joaquín Ferrero C<< explorer at joaquinferrero.com >>
and Enrique Nell C<< blas.gordon at gmail.com >>.


=head1 SEE ALSO

L<POD2::PT_BR>, L<POD2::IT>, L<POD2::FR>, L<POD2::LT>, L<perl>.

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2007-2010 by Enrique Nell, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
