# ABSTRACT: Config role for Dancer2 core objects
package Dancer2::Core::Role::ConfigReader;

use Moo::Role;

use File::Spec;
use Config::Any;
use Hash::Merge::Simple;
use Carp 'croak';
use Module::Runtime 'require_module';

use Dancer2::Core::Factory;
use Dancer2::Core;
use Dancer2::Core::Types;
use Dancer2::FileUtils 'path';

with 'Dancer2::Core::Role::HasLocation';

has config_location => (
    is      => 'ro',
    isa     => ReadableFilePath,
    lazy    => 1,
    default => sub { $ENV{DANCER_CONFDIR} || $_[0]->location },
);

# The type for this attribute is Str because we don't require
# an existing directory with configuration files for the
# environments.  An application without environments is still
# valid and works.
has environments_location => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub {
        $ENV{DANCER_ENVDIR}
          || File::Spec->catdir( $_[0]->config_location, 'environments' )
          || File::Spec->catdir( $_[0]->location,        'environments' );
    },
);

has environment => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub _normalize_config {
    my ( $self, $config ) = @_;

    foreach my $key ( keys %{$config} ) {
        my $value = $config->{$key};
        $config->{$key} = $self->_normalize_config_entry( $key, $value );
    }
    return $config;
}

sub _compile_config {
    my ( $self, $config ) = @_;

    foreach my $key ( keys %{$config} ) {
        my $value = $config->{$key};
        $config->{$key} =
          $self->_compile_config_entry( $key, $value, $config );
    }
    return $config;
}

1;

__END__

=head1 DESCRIPTION

This is the redesigned Dancer2::Core::Role to manage
the Dancer2 configuration. Unlike earlier when config
was read from files at the start of the web app,
now config can be reread at a request. Also config is
not created at the time of reading the class.

This new behaviour makes it possible to attach plugins
via hooks to influence config reading.

It also becomes possible to reload configuration without
restarting the app.

Provides a C<config> attribute that - when accessing
the first time - feeds itself by finding and parsing
configuration files.

Also provides a C<setting()> method which is supposed to be used by externals to
read/write config entries.

=head1 ATTRIBUTES

=attr location

Absolute path to the directory where the server started.

=attr config_location

Gets the location from the configuration. Same as C<< $object->location >>.

=attr environments_location

Gets the directory where the environment files are stored.

=attr config

Returns the whole configuration.

=attr environments

Returns the name of the environment.

=head1 METHODS

=head2 settings

Alias for config. Equivalent to <<$object->config>>.

=head2 setting

Get or set an element from the configuration.

=head2 has_setting

Verifies that a key exists in the configuration.

=head2 load_config_file

Load the configuration files.
