use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Attribute::Util',
    'VERSION_FROM'	=> 'Util.pm', # finds $VERSION
    'PREREQ_PM'		=> {
    	Attribute::Handlers => '0.61',
	Memoize             => 0,
    },
    dist                => {
        # don't ask about existing .tar.gz files
        COMPRESS => 'gzip --force --best'
    },
);
