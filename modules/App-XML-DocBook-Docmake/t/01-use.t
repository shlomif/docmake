#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Trap qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

use App::XML::DocBook::Docmake;

package MyTest::DocmakeAppDebug;

use vars qw(@commands_executed);

use base 'App::XML::DocBook::Docmake';

sub _exec_command
{
    my ($self, $cmd) = @_;
    
    push @commands_executed, [@$cmd];
}

sub debug_commands
{
    my @ret = @commands_executed;

    # Reset the commands to allow for future use.
    @commands_executed = ();

    return \@ret;
}

package main;

{
    my $docmake = App::XML::DocBook::Docmake->new({argv => ["help"]});

    # TEST
    ok ($docmake, "Testing that docmake was initialized");
}

{
    my $docmake = App::XML::DocBook::Docmake->new({argv => ["help"]});
    
    trap { $docmake->run(); };

    # TEST
    like ($trap->stdout(),
          qr{Docmake version.*^A tool to convert DocBook/XML to other formats.*^Available commands:\n}ms,
          "Testing output of help"
    );
}

{
    my $docmake = MyTest::DocmakeAppDebug->new({argv => [
            "-v",
            "--stringparam",
            "chunk.section.depth=2",
            "-o", "output.xhtml",
            "xhtml",
            "input.xml",
            ]});

    # TEST
    ok ($docmake, "Docmake was constructed successfully");

    $docmake->run();

    # TEST
    is_deeply(MyTest::DocmakeAppDebug->debug_commands(),
        [
            [
                "xsltproc",
                "-o", "output.xhtml",
                "--stringparam", "chunk.section.depth", "2",
                "http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl",
                "input.xml",
            ]
        ],
        "stringparam is propagated to the xsltproc command",
    );
}

