use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'App::XML::DocBook::Builder',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/App/XML/DocBook/Builder.pm',
    build_requires => {
        'Test::More' => 0,
        'Test::Trap' => 0,

    },
    requires => {
            'Getopt::Long' => '2.37',
    },
    add_to_cleanup      => [ 'App::XML::DocBook::Builder-*' ],
    script_files => [ "script/docmake" ],
);

$builder->create_build_script();
