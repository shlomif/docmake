package App::XML::DocBook::Docmake::CmdComponent;

use strict;
use warnings;

use Class::XSAccessor {
    accessors => [

        qw(
            is_input
            is_output
        )
    ]
};

sub new
{
    my ( $class, $self ) = @_;
    return bless $self, $class;
}

1;

__END__

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 is_input

B<FOR INTERNAL USE>.

=head2 is_output

B<FOR INTERNAL USE>.

=head2 new

B<FOR INTERNAL USE>.

=head2

=cut

