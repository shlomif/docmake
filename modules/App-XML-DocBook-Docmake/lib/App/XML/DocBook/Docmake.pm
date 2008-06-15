package App::XML::DocBook::Docmake;

use Getopt::Long qw(GetOptionsFromArray);

use base 'Class::Accessor';

=head1 NAME

App::XML::DocBook::Docmake - translate DocBook/XML to other formats

=head1 VERSION

Version 0.01

=cut

__PACKAGE__->mk_accessors(qw(
    _input_path
    _mode
    _output_path
    _stylesheet
    _verbose
    _xslt_mode
));

=head1 SYNOPSIS

    use App::XML::DocBook::Docmake;

    my $docmake = App::XML::DocBook::Docmake->new({argv => [@ARGV]});

    $docmake->run()

=head1 FUNCTIONS

=head2 my $obj = App::XML::DocBook::Docmake->new({argv => [@ARGV]})

Instantiates a new object.

=cut

my %modes = 
(
    'fo' =>
    {
    },
    'help' =>
    {
        standalone => 1,
    },
    'xhtml' =>
    {
    },
    'rtf' =>
    {
        xslt_mode => "fo",
    },
    'pdf' =>
    {
        xslt_mode => "fo",
    },
);

sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->_init(@_);

    return $self;
}

sub _init
{
    my ($self, $args) = @_;

    my $argv = $args->{'argv'};

    my $output_path;
    my $verbose = 0;
    my $stylesheet;

    my $ret = GetOptionsFromArray($argv,
        "o=s" => \$output_path,
        "v|verbose" => \$verbose,
        "x|stylesheet=s" => \$stylesheet,
    );

    $self->_output_path($output_path);
    $self->_verbose($verbose);
    $self->_stylesheet($stylesheet);

    my $mode = shift(@$argv);

    my $mode_struct = $modes{$mode};

    if ($mode_struct)
    {
        $self->_mode($mode);
        if ($mode_struct->{xslt_mode})
        {
            $self->_xslt_mode($mode_struct->{xslt_mode});
        }
        else
        {
            $self->_xslt_mode($self->_mode());
        }
    }
    else
    {
        die "Unknown mode \"$mode\"";
    }

    my $input_path = shift(@$argv);

    if (! (defined($input_path) || $mode_struct->{standalone}) )
    {
        die "Input path not specified on command line";
    }
    else
    {
        $self->_input_path($input_path);
    }

    return;
}

=head2 $docmake->run()

Runs the object.

=cut

sub _exec_command
{
    my ($self, $cmd) = @_;

    if ($self->_verbose())
    {
        print (join(" ", @$cmd), "\n");
    }
    return system(@$cmd);
}

sub run
{
    my $self = shift;

    my $mode = $self->_mode();

    my $mode_func = "_run_mode_$mode";

    return $self->$mode_func(@_);
}

sub _run_mode_help
{
    my $self = shift;

    print <<"EOF";
Docmake version $VERSION
A tool to convert DocBook/XML to other formats

Available commands:

    help - this help screen.
    
    fo - convert to XSL-FO.
    rtf - convert to RTF (MS Word).
    pdf - convert to PDF (Adobe Acrobat).
    xhtml - convert to XHTML.
EOF
}

sub _run_mode_fo
{
    my $self = shift;
    return $self->_run_xslt();
}

sub _run_mode_xhtml
{
    my $self = shift;

    return $self->_run_xslt();
}

sub _calc_default_xslt_stylesheet
{
    my $self = shift;

    my $mode = $self->_xslt_mode();

    return 
        "http://docbook.sourceforge.net/release/xsl/current/${mode}/docbook.xsl"
        ;
}

sub _run_xslt
{
    my $self = shift;
    my $args = shift;

    my @stylesheet_params = ($self->_calc_default_xslt_stylesheet());

    if (defined($self->_stylesheet()))
    {
        @stylesheet_params = ($self->_stylesheet());
    }
    
    my $output_path = $self->_output_path();
    if (defined($args->{output_path}))
    {
        $output_path = $args->{output_path};
    }

    if (!defined($output_path))
    {
        die "Output path not specified!";
    }

    return $self->_exec_command(
        [
            "xsltproc",
            "-o", $output_path,
            @stylesheet_params,
            $self->_input_path(),
        ],
    );
}

sub _run_mode_pdf
{
    my $self = shift;

    my $xslt_output_path = $self->_output_path();

    $xslt_output_path =~ s{\.([^\.]*)\z}{\.fo}ms;

    $self->_run_xslt({output_path => $xslt_output_path});

    return $self->_exec_command(
        [
            "fop",
            "-pdf", $self->_output_path(),
            $xslt_output_path,
        ],
    );
}

sub _run_mode_rtf
{
    my $self = shift;

    my $xslt_output_path = $self->_output_path();

    $xslt_output_path =~ s{\.([^\.]*)\z}{\.fo}ms;

    $self->_run_xslt({output_path => $xslt_output_path});

    return $self->_exec_command(
        [
            "fop",
            "-rtf", $self->_output_path(),
            $xslt_output_path,
        ],
    );
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-app-docbook-xml-docmake at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App::XML::DocBook::Docmake>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::XML::DocBook::Docmake

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App::XML::DocBook::Docmake>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App::XML::DocBook::Docmake>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App::XML::DocBook::Docmake>

=item * Search CPAN

L<http://search.cpan.org/dist/App::XML::DocBook::Docmake>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 License.
( L<http://www.opensource.org/licenses/mit-license.php> ).

=cut

1;

