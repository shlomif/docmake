package App::Docmake;

use 5.014;
use strict;
use warnings;

use parent 'App::XML::DocBook::Docmake';

=head1 NAME

App::Docmake - translate DocBook/XML to other formats

=head1 SYNOPSIS

    use App::Docmake ();

    my $docmake = App::Docmake->new({argv => [@ARGV]});

    $docmake->run()

=head1 DESCRIPTION

Created as a shorthand namespace so people can say
C<cpanm App::Docmake> or similar.

=head1 SEE ALSO

L<App::XML::DocBook::Docmake>

=cut

1;
