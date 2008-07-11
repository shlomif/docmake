#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 12;
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

sub _mkdir
{
    # Do nothing - to override.
}

sub debug_commands
{
    my @ret = @commands_executed;

    # Reset the commands to allow for future use.
    @commands_executed = ();

    return \@ret;
}

package MyTest::DocmakeAppDebug::Newer;

use vars qw($should_update);

use vars qw(@ISA);

@ISA=('MyTest::DocmakeAppDebug');

sub _should_update_output
{
    return $should_update->(@_);
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
            "-o", "my-output-dir",
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
                "-o", "my-output-dir/",
                "--stringparam", "chunk.section.depth", "2",
                "http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl",
                "input.xml",
            ]
        ],
        "stringparam is propagated to the xsltproc command",
    );
}

{
    my @should_update;
    local $MyTest::DocmakeAppDebug::Newer::should_update = sub {
        my $self = shift;
        my $args = shift;
        push @should_update,
            [ map { $_ => $args->{$_} } 
             sort { $a cmp $b }
             keys(%$args)
            ]
            ;
        return 1;
    };
    my $docmake = MyTest::DocmakeAppDebug::Newer->new({argv => [
            "-v",
            "--make",
            "-o", "GOTO-THE-output.pdf",
            "pdf",
            "MYMY-input.xml",
            ]});

    # TEST
    ok ($docmake, "Docmake was constructed successfully");

    $docmake->run();

    # TEST
    is_deeply(MyTest::DocmakeAppDebug->debug_commands(),
        [
            [
                "xsltproc",
                "-o", "GOTO-THE-output.fo",
                "http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl",
                "MYMY-input.xml",
            ],
            [
                "fop",
                "-pdf",
                "GOTO-THE-output.pdf",
                "GOTO-THE-output.fo",
            ],
        ],
        "Making sure all commands got run",
    );

    # TEST
    is_deeply(\@should_update,
        [
            [ "input", "MYMY-input.xml", "output", "GOTO-THE-output.fo"],
            [ "input", "GOTO-THE-output.fo", "output", "GOTO-THE-output.pdf" ],
        ],
        "should update is OK.",
    );
}

{
    my @should_update;
    local $MyTest::DocmakeAppDebug::Newer::should_update = sub {
        my $self = shift;
        my $args = shift;
        push @should_update,
            [ map { $_ => $args->{$_} } 
             sort { $a cmp $b }
             keys(%$args)
            ]
            ;
        return 0;
    };
    my $docmake = MyTest::DocmakeAppDebug::Newer->new({argv => [
            "-v",
            "--make",
            "-o", "GOTO-THE-output.pdf",
            "pdf",
            "MYMY-input.xml",
            ]});

    # TEST
    ok ($docmake, "Docmake was constructed successfully");

    $docmake->run();

    # TEST
    is_deeply(MyTest::DocmakeAppDebug->debug_commands(),
        [
        ],
        "No commands got run because of should_update",
    );

    # TEST
    is_deeply(\@should_update,
        [
            [ "input", "MYMY-input.xml", "output", "GOTO-THE-output.fo"],
            [ "input", "GOTO-THE-output.fo", "output", "GOTO-THE-output.pdf" ],
        ],
        "should update is OK.",
    );
}

{
    my $docmake = MyTest::DocmakeAppDebug->new({argv => [
            "-v",
            "-o", "my-output",
            "pdf",
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
                "-o", "my-output.fo",
                "http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl",
                "input.xml",
            ],
            [
                "fop",
                "-pdf",
                "my-output",
                "my-output.fo",
            ],
        ],
        "testing that .fo is added if the pdf filename does not contain a prefix",
    );
}
