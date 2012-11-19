use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WWW::Foursquare',
    AUTHOR           => q{Pavel Vlasov <fxzuz@cpan.org>},
    VERSION_FROM     => 'lib/WWW/Foursquare.pm',
    ABSTRACT_FROM    => 'lib/WWW/Foursquare.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'JSON' => 2,
        'URI'  => 1, 
        'LWP'  => 6,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WWW-Foursquare-*' },
);
