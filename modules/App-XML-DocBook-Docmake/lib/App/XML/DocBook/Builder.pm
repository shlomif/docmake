package App::XML::DocBook::Builder;

use 5.014;
use strict;
use warnings;
use autodie;

sub new
{
    my $class = shift;

    return bless {}, $class;
}

1;

=head1 NAME

App::XML::DocBook::Builder - Build DocBook/XML files.

=head1 SYNOPSIS

    use App::XML::DocBook::Builder ();

    my $foo = App::XML::DocBook::Builder->new();

=cut

my $inst_dir = "$ENV{HOME}/apps/docbook-builder";

=head1 FUNCTIONS

=head2 new

A constructor.

=head2 initialize_makefiles($args)

Initialize the makefile in the directory.

Accepts one named argument which is "doc_base" for the document base name.

=cut

sub initialize_makefiles
{
    my $self = shift;

    my $args = shift;

    my $redirect_makefile = "docmake.mak";

    open my $docbook_mak, ">", $redirect_makefile;

    print {$docbook_mak} <<"EOF";
DOCBOOK_MAK_PATH = $inst_dir

DOCBOOK_MAK_MAKEFILES_PATH = \$(DOCBOOK_MAK_PATH)/share/make/

include \$(DOCBOOK_MAK_MAKEFILES_PATH)/main-docbook.mak
EOF

    close($docbook_mak);

    open my $main_mak, ">", "Makefile.main";
    print {$main_mak} "DOC = "
        . $args->{doc_base}
        . "\n\ninclude $redirect_makefile\n\n";
    close($main_mak);

    return;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish.

This program is released under the following license: MIT/X11

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;    # End of App::XML::DocBook::Builder
