#!/usr/bin/perl

use strict;
use warnings;

use IO::All;

my ($version) = 
    (map { m{\$VERSION *= *'([^']+)'} ? ($1) : () } 
    io->file("./lib/App/XML/DocBook/Docmake.pm")->getlines()
    )
    ;

if (!defined ($version))
{
    die "Version is undefined!";
}

my $mini_repos_url = "https://svn.berlios.de/svnroot/repos/web-cpan/App-XML-DocBook-Docmake/";

my @cmd = (
    "svn", "copy", "-m",
    "Tagging App-XML-DocBook-Docmake as $version",
    "$mini_repos_url/trunk",
    "$mini_repos_url/tags/cpan-releases/$version",
);

print join(" ", map { /\s/ ? qq{"$_"} : $_ } @cmd), "\n";
exec(@cmd);
