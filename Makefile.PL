#use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Test::C2FIT',
    VERSION_FROM      => 'lib/Test/C2FIT.pm', # finds $VERSION
    PREREQ_PM         => {
				Test::Unit => 0.24
			}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Test/C2FIT.pm', # retrieve abstract from module
       AUTHOR         => 'Tony Byrne <fit4perl@byrnehq.com>') : ()),
);
