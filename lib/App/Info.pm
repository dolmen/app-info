package App::Info;

# $Id: Info.pm,v 1.28 2002/06/14 02:15:14 david Exp $

=head1 NAME

App::Info - Information about software packages on a system

=head1 SYNOPSIS

  use App::Info::Category::FooApp;

  my $app = App::Info::Category::FooApp->new;

  if ($app->installed) {
      print "App name: ", $app->name, "\n";
      print "Version:  ", $app->version, "\n";
      print "Bin dir:  ", $app->bin_dir, "\n";
  } else {
      print "App not installed on your system. :-(\n";
  }

=head1 DESCRIPTION

App::Info is an abstract base class designed to provide a generalized
interface for subclasses that provide metadata about software packages
installed on a system. The idea is that these classes can be used in Perl
application installers in order to determine whether software dependencies
have been fulfilled, and to get necessary metadata about those software
packages.

A few L<sample subclasses|"SEE ALSO"> are provided with the distribution, but
others are invited to write their own subclasses and contribute them to the
CPAN. Contributors are welcome to extend their subclasses to provide more
information relevant to the application for which data is to be provided (see
L<App::Info::HTTPD::Apache|App::Info::HTTPD::Apache> for an example), but are
encouraged to, at a minimum, implement the abstract methods defined here and
in the category abstract base classes (e.g.
L<App::Info::HTTPD|App::Info::HTTPD> and L<App::Info::Lib|App::Info::Lib>. See
L<Subclassing|"SUBCLASSING"> for more information on implementing new
subclasses.

=cut

use strict;
use Carp ();
use App::Info::Handler;
use App::Info::Request;
use vars qw($VERSION);

$VERSION = '0.13';

my $croak = sub {
    my ($caller, $meth) = @_;
    $caller = ref $caller || $caller;
    if ($caller eq __PACKAGE__) {
        $meth = __PACKAGE__ . '::' . shift;
        Carp::croak(__PACKAGE__ . " is an abstract base class. Attempt to " .
                    " call non-existent method $meth");
    } else {
        Carp::croak("Class $caller inherited from the abstract base class " .
                    __PACKAGE__ . ", but failed to redefine the $meth() " .
                    "method. Attempt to call non-existent method " .
                    "${caller}::$meth");
    }
};

my $set_handlers = sub {
    my $on_key = shift;
    # Default is to do nothing.
    return [] unless $on_key;
    my $ref = ref $on_key;
    if ($ref) {
        $on_key = [$on_key] unless $ref eq 'ARRAY';
        # Make sure they're all handlers.
        foreach my $h (@$on_key) {
            if (my $r = ref $h) {
                Carp::croak("$r object is not an App::Info::Handler")
                  unless UNIVERSAL::isa($h, 'App::Info::Handler');
            } else {
                # Look up the handler.
                $h = App::Info::Handler->new($h);
            }
        }
        # Return 'em!
        return $on_key;
    } else {
        # Look up the handler.
        return [ App::Info::Handler->new($on_key) ];
    }
};

=head1 CONSTRUTOR

=head2 new

  my $app = App::Info::Category::FooApp->new(@params);

Consructs the FooApp App::Info object and returns it. The @params arguments
define how the App::Info object will respond to certain events, and correspond
to their like-named methods. See L<Event Handler Object Methods|"EVENT HANDLER
OBJECT METHODS"> for more information on App::Info events and how to handle
them. The parameters to C<new()> for the different types of App::Info events
are as follows:

=over 4

=item on_info

=item on_error

=item on_unknown

=item on_confirm

=back

When passing in event handlers to C<new()>, the list of handlers for each even
type should be an anonymous array:

  my $app = App::Info::Category::FooApp->new(on_info => [@handlers]);

=cut

sub new {
    my ($pkg, %p) = @_;
    my $class = ref $pkg || $pkg;
    # Fail if the method isn't overridden.
    $croak->($pkg, 'new') if $class eq __PACKAGE__;

    # Set up handlers.
    for (qw(on_error on_unknown on_info on_confirm)) {
        $p{$_} = $set_handlers->($p{$_});
    }

    # Do it!
    return bless \%p, $class;
}

=head1 METADATA OBJECT METHODS

These are abstract methods in App::Info and must be provided by its
subclasses. They provide the essential metadata of the software package
supported by the App::Info subclass.

=head2 installed

  if ($app->installed) {
      print "App is installed.\n"
  } else {
      print "App is not installed.\n"
  }

Returns a true value if the application is installed, and a false value if it
is not.

=cut

sub installed { $croak->(shift, 'installed') }

=head2 name

  my $name = $app->name;

Returns the name of the application.

=cut

sub name { $croak->(shift, 'name') }

=head2 version

  my $version = $app->version;

Returns the full version number of the application.

=cut

sub version { $croak->(shift, 'version') }

=head2 major_version

  my $major_version = $app->major_version;

Returns the major version number of the application. For example, if
C<version()> returns "7.1.2", then this method returns "7".

=cut

sub major_version { $croak->(shift, 'major_version') }

=head2 minor_version

  my $minor_version = $app->minor_version;

Returns the minor version number of the application. For example, if
C<version()> returns "7.1.2", then this method returns "1".

=cut

sub minor_version { $croak->(shift, 'minor_version') }

=head2 patch_version

  my $patch_version = $app->patch_version;

Returns the patch version number of the application. For example, if
C<version()> returns "7.1.2", then this method returns "2".

=cut

sub patch_version { $croak->(shift, 'patch_version') }

=head2 bin_dir

  my $bin_dir = $app->bin_dir;

Returns the full path the application's bin directory, if it exists.

=cut

sub bin_dir { $croak->(shift, 'bin_dir') }

=head2 inc_dir

  my $inc_dir = $app->inc_dir;

Returns the full path the application's include directory, if it exists.

=cut

sub inc_dir { $croak->(shift, 'inc_dir') }

=head2 lib_dir

  my $lib_dir = $app->lib_dir;

Returns the full path the application's lib directory, if it exists.

=cut

sub lib_dir { $croak->(shift, 'lib_dir') }

=head2 so_lib_dir

  my $so_lib_dir = $app->so_lib_dir;

Returns the full path the application's shared library directory, if it
exists.

=cut

sub so_lib_dir { $croak->(shift, 'so_lib_dir') }

=head2 home_url

  my $home_url = $app->home_url;

The URL for the software's home page.

=cut

sub home_url  { $croak->(shift, 'home_url') }

=head2 download_url

  my $download_url = $app->download_url;

The URL for the software's download page.

=cut

sub download_url  { $croak->(shift, 'download_url') }

=head1 EVENT HANDLER OBJECT METHODS

These methods provide control over event App::Info event handling. Events can
be handled by one or more more objects of subclasses of App::Info::Handler --
the first to return a true value will be the last to execute. This allows you
to stack handlers, if you wish, or to implement your own. See
L<App::Info::Handler|App::Info::Handler> for information on writing event
handlers.

Each of the event handler methods takes a list of event handlers as their
arguments. If none are passed, the existing list of handlers for the relevant
event type will be returned. If new handlers are passed in, they will be
retrurned.

The event handlers may be specified as one or more objects of the
App::Info::Handler class or subclasses, as one or more strings that tell
App::Info construct such handlers itself, or a combination of the two. The
strings can only be used if the relevant App::Info::Handler subclasses have
registered the appropriate strings with App::Info. For example, the
App::Info::Handler::Print class included in the App::Info distribution
registers the strings "stderr" and "stdout" when it starts up. These strings
may then be used to tell App::Info to construct App::Info::Handler::Print
objects that print to STDERR or to STDOUT, respectively. See the
App::Info::Handler subclasses for what strings they register with App::Info.

=head2 on_info

  my @handlers = $app->on_info;
  $app->on_info(@handlers);

Info events are triggered when the App::Info subclass wants to send an
informational status message to the user. By default, these events are
ignored, but a common need is for such messages to simply print to STDOUT. Use
the L<App::Info::Handler::Print|App::Info::Handler::Print> class included with
the App::Info distribution to have info messages print to STDOUT:

  use App::Info::Handler::Print;
  $app->on_info('stdout');
  # Or:
  my $stdout_handler = App::Info::Handler::Print->new('stdout');
  $app->on_info($stdout_handler);

=cut

sub on_info {
    my $self = shift;
    $self->{on_info} = $set_handlers->(\@_) if @_;
    return @{ $self->{on_info} };
}

=head2 on_error

  my @handlers = $app->on_error;
  $app->on_error(@handlers);

Error events are triggered when the App::Info subclass runs into an unexpected
but not fatal problem. (Note that fatal problems will likely throw an
exception.) By default, these events are ignored. A common way of handling
these events is to print to STDERR, once again using the
L<App::Info::Handler::Print|App::Info::Handler::Print> class included with the
App::Info distribution:

  use App::Info::Handler::Print;
  my $app->on_error('stderr');
  # Or:
  my $stderr_handler = App::Info::Handler::Print->new('stderr');
  $app->on_error($stderr_handler);

Another approach might be to turn such events into fatal exceptions. Use the
included L<App::Info::Handler::Carp|App::Info::Handler::Carp> class for this
purpose:

  use App::Info::Handler::Carp;
  my $app->on_error('croak');
  # Or:
  my $croaker = App::Info::Handler::Carp->new('croak');
  $app->on_error($croaker);

=cut

sub on_error {
    my $self = shift;
    $self->{on_error} = $set_handlers->(\@_) if @_;
    return @{ $self->{on_error} };
}

=head2 on_unknown

  my @handlers = $app->on_unknown;
  $app->on_uknown(@handlers);

Unknown events are trigged when the App::Info subclass cannot find the value
to be returned by a method call. By default, these events are ignored. A
common way of handling them is to have the application prompt the user for the
relevant data. The App::Info::Handler::Prompt class included with the
App::Info distribution can do just that:

  use App::Info::Handler::Prompt;
  my $app->on_unknown('prompt');
  # Or:
  my $prompter = App::Info::Handler::Prompt;
  $app->on_unknown($prompter);

See L<App::Info::Handler::Prompt|App::Info::Handler::Prompt> for information
on how it works.

=cut

sub on_unknown {
    my $self = shift;
    $self->{on_unknown} = $set_handlers->(\@_) if @_;
    return @{ $self->{on_unknown} };
}

=head on_confirm

  my @handlers = $app->on_confirm;
  $app->on_confirm(@handlers);

Confirm events are triggered when the App::Info subclass has found an
important piece of information (such as the location of the binary it'll use
to collect information for the rest of its methods) and wants to confirm that
the information is correct. These events will most often be triggered during
the App::Info subclass object construction. Here, too, the
App::Info::Handler::Prompt class included with the App::Info distribution can
help out:

  use App::Info::Handler::Prompt;
  my $app->on_confirm('prompt');
  # Or:
  my $prompter = App::Info::Handler::Prompt;
  $app->on_confirm($prompter);

Again, consult the L<App::Info::Handler::Prompt|App::Info::Handler::Prompt>
documentation for details on its operation.

=cut

sub on_confirm {
    my $self = shift;
    $self->{on_confirm} = $set_handlers->(\@_) if @_;
    return @{ $self->{on_confirm} };
}

=head1 SUBCLASSING

The organizational idea behind App::Info is to name subclasses by broad
software categories. This approach allows the categories to function as
abstract base classes that extend App::Info, so that they can specify more
methods for all of their base classes to implement. For example,
L<App::Info::HTTPD> has specified the C<httpd_root()> abstract method that its
subclasses must implement. So as you get ready to implement your own subclass,
think about what category of software you're gathering information about.

Here are some guidelines for subclassing App::Info.

=over 4

=item *

Always subclass an App::Info category subclass. This will help to keep the
App::Info namespace well-organized. New categories can be added as needed.

=item *

When you create the new() constructor, always call SUPER::new(). This ensures
that the methods handle by the App::Info base classes (e.g., C<error()>) work
properly.

=item *

Use a package-scoped lexical App::Info::Util object to carry out common tasks.
If you find you're doing something over and over that's not already addressed
by an App::Info::Util method, consider submitting a patch to App::Info::Util
to add the functionality you need. See L<App::Info::Util|App::Info::Util> for
complete documentation of its interface.

=item *

Use the C<error()> method to report problems to clients of your App::Info
subclass. Doing so ensures that all problems encountered in interrogating
software package can be reported to and handled by client users in a uniform
manner. Furthermore, don't assume that calling C<error()> causes the program
to exit or to return from method execution. Clients can choose to ignore
errors by using the "silent" C<error_level>. Of course, fatal problem should
still be fatal, but non-fatal issues -- such as when an important file cannot
be found, resulting in less metadata being provided by the App::Info object --
should be noted by use of the C<error()> method exclusively.

=item *

Be sure to implement B<all> of the abstract methods defined by your category
abstract base class -- even if they don't do anything. Doing so ensures that
all App::Info subclasses share a common interface, and can, if necessary, be
used without regard to subclass. Any method not implemented but called on an
object will generate a fatal exception.

=back

Feel free to use the subclasses included in this distribution as examples to
follow when creating your own subclasses. I've tried to encapsulate common
functionality in L<App::Info::Util|App::Info::Util> to make the job easier. I
found that most of what I was doing repetitively was looking for files and
directories, and searching through files. Thus, App::Info::Util subclasses
L<File::Spec|File::Spec> in order to offer easy access to commonly-used
methods from that class (e.g., C<path()>. Plus, it has several of its own
methods to assist you in finding files and directories in lists of files and
directories, as well as methods for searching through files and returning the
values found in those files. See L<App::Info::Util|App::Info::Util> for more
information, and the App::Info subclasses in this distribution for actual
usage examples.

Otherwise, have fun! There are a lot of software packages for which relevant
information might be collected and aggregated into an App::Info subclass
(witness all of the Automake macros in the world!), and folks who are
knowledgeable about particular software packages or categories of software are
warmly invited to contribute. As more subclasses are implemented, it will make
sense, I think, to create separate distributions based on category -- or even,
when necessary, on a single software package. Broader categories can then be
aggregated in Bundle distributions.

But I get ahead of myself...

=cut

my $handler = sub {
    my ($self, $meth, $params) = @_;

    # Sanity check. We really want to keep control over this.
    Carp::croak("Cannot call protected method $meth()")
      unless UNIVERSAL::isa($self, scalar caller(1));

    # Create the request object.
    $params->{type} ||= $meth;
    my $req = App::Info::Request->new($params);

    # Do the deed. The ultimate handling handler may die.
    foreach my $eh (@{$self->{"on_$meth"}}) {
        last if $eh->handler($req);
    }

    # Return the requst.
    return $req;
};

sub info {
    my $self = shift;
    # Execute the handler sequence.
    my $req = $handler->($self, 'info', { message => join '', @_ });
}

sub error {
    my $self = shift;
    # Execute the handler sequence.
    my $req = $handler->($self, 'error', { message => join '', @_ });
}

sub unknown {
    my ($self, $key, $prompt, $cb, $err, $sigil) = @_;

    # Create a prompt, if necessary.
    unless ($prompt) {
        my $name = $self->key_name;
        $prompt = "Enter a valid $name $key";
    }
    $err ||= 'Invalid value';

    # Prepare the request arguments.
    my $params = { message  => $prompt,
                   error    => $err,
                   sigil    => $sigil,
                   callback => $cb };

    # Execute the handler sequence.
    my $req = $handler->($self, "unknown", $params);
    return $req->value;
}

sub confirm {
    my ($self, $key, $prompt, $val, $cb, $err, $sigil) = @_;
    # Just return the value if we've already confirmed this value.
    return $val if $self->{__confirm__}{$key};

    # Create a prompt, if necessary.
    unless ($prompt) {
        my $name = $self->key_name;
        $prompt = "Enter a valid $name $key";
    }
    $err ||= 'Invalid value';

    # Prepare the request arguments.
    my $params = { message  => $prompt,
                   error    => $err,
                   value    => $val,
                   sigil    => $sigil,
                   callback => $cb };

    # Execute the handler sequence.
    my $req = $handler->($self, "confirm", $params);

    # Mark that we've confirmed this value.
    $self->{"_conf_$key"} = 1;

    return $req->value;
}

1;
__END__

=head1 BUGS

Can there really be much in the way of bugs in an abstract base class? Drop me
a line if you happen to discover any.

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<App::Info::Lib|App::Info::HTTPD>,
L<App::Info::Lib|App::Info::RDBMS>,
L<App::Info::Lib|App::Info::Lib>,
L<App::Info::HTTPD::Apache|App::Info::HTTPD::Apache>,
L<App::Info::RDBMS::PostgreSQL|App::Info::RDBMS::PostgreSQL>,
L<App::Info::Lib|App::Info::Lib::Expat>,
L<App::Info::Lib|App::Info::Lib::Iconv>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
