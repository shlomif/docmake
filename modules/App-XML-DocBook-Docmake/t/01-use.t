#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Test::Trap qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

use App::XML::DocBook::Docmake;

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
