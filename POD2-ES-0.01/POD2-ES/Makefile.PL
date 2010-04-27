use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'POD2::ES',
    VERSION_FROM      => 'lib/POD2/ES.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/POD2/ES.pm', # retrieve abstract from module
       AUTHOR         => 'Enrique Nell <blas.gordon@gmail.com>') : ()),
);
