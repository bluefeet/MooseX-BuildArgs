package MooseX::BuildArgs;
use Moose::Role;

=head1 NAME

MooseX::BuildArgs - Save the original constructor arguments for later use.

=head1 SYNOPSIS

Create a class that uses this module:

    package MyClass;
    use Moose;
    use MooseX::BuildArgs;
    has foo => ( is=>'ro', isa=>'Str' );

Then whenever an instance of this class is created all arguments to the
constructor are saved in the build_args attribute:

    use MyClass;
    my $object = MyClass->new( foo => 32 );
    print $object->build_args->{foo};

=head1 DESCRIPTION

Sometimes it is very useful to have access the the contructor arguments before builders,
defaults, and coercion take affect.  This module provides a build_args hashref attribute
for all instances of the consuming class.  The build_args attribute contains all arguments
that were passed to the constructor.

A typical case for this module would be for creating a clone of an object, so you could
duplicate an object with the following code:

    my $obj1 = MyClass->new( foo => 32 );
    my $obj2 = MyClass->new( $obj1->build_args() );
    print $obj2->foo();

=cut

Moose::Exporter->setup_import_methods();

sub init_meta {
    shift;
    my %args = @_;

    Moose->init_meta( %args );

    my $class = $args{for_class};

    Moose::Util::MetaRole::apply_base_class_roles(
        for_class => $class,
        roles => [ 'MooseX::BuildArgs::Role' ],
    );

    return $class->meta();
}

{
    package MooseX::BuildArgs::Role;
    use Moose::Role;

    has build_args => (
        is       => 'ro',
        isa      => 'HashRef',
        required => 1,
        init_arg => '_build_args',
    );

    around BUILDARGS => sub{
        my $orig = shift;
        my $self = shift;

        my $args = $self->$orig( @_ );

        $args->{_build_args} = { %$args };

        return $args;
    };
}

1;
__END__

=head1 AUTHOR

Aran Clary Deltac <bluefeet@gmail.com>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

