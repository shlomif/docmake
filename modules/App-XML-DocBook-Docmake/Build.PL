use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::XML::DocBook::Builder',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/App/XML/DocBook/Builder.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'App::XML::DocBook::Builder-*' ],
    script_files => [ "bin/docmake" ],
);

$builder->create_build_script();
