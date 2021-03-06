package Log::Any::Adapter::Sentry::Raven;

# ABSTRACT: Log::Any::Adapter for Sentry::Raven
# VERSION

=head1 SYNPOSIS

    use Log::Any::Adapter;
    Log::Any::Adapter->set('Sentry::Raven',
        sentry => Sentry::Raven->new(
            sentry_dsn  => $dsn,
            environment => 'production',
            ...
        )
    );

=head1 DESCRIPTION

This is a backend to L<Log::Any> for L<Sentry::Raven>.

When logging, it does its best to provide a L<Devel::StackTrace> to
identify your message. To accomplish this, it uses L<Devel::StackTrace::Extract>
to pull a trace from your message (if you pass multiple message arguments, it
won't attempt this).
Failing that, it will append a new C<Devel::StackTrace>.

It takes two arguments:

=over

=item sentry (REQUIRED)

An instantiated L<Sentry::Raven> object.
Note that if you set any sentry-specific context directly through the sentry
object, it will be picked up here eg.

    $sentry->add_context( Sentry::Raven->request_context($url, %p) )

=item log_level (OPTIONAL)

The minimum log_level to log. Defaults to C<trace> (everything).

=back

Any L<Log::Any/Log context data> will be sent to Sentry as tags.

=head1 SEE ALSO

L<Log::Any>, L<Sentry::Raven>

=cut

use strict;
use warnings;

use Carp qw(carp croak);
use Devel::StackTrace;
use Devel::StackTrace::Extract qw(extract_stack_trace);
use Log::Any::Adapter::Util qw(make_method numeric_level);
use Scalar::Util qw(blessed);
use Sentry::Raven;

use base qw(Log::Any::Adapter::Base);

sub init {
    my $self = shift;

    my $sentry = $self->{sentry};
    croak "An initialized Sentry::Raven object must be passed as the 'sentry' arg"
        unless blessed($sentry) && $sentry->isa('Sentry::Raven');

    # copied from Log::Any::Adapter::Stderr
    if ( exists $self->{log_level} && $self->{log_level} =~ /\D/ ) {
        my $numeric_level = numeric_level( $self->{log_level} );
        if ( !defined($numeric_level) ) {
            carp( sprintf 'Invalid log level "%s". Defaulting to "%s"', $self->{log_level}, 'trace' );
        }
        $self->{log_level} = $numeric_level;
    }
    if ( !defined $self->{log_level} ) {
        $self->{log_level} = numeric_level('trace');
    }
}

sub structured {
    my ($self, $level, $category, @log_args) = @_;

    my $is_level = "is_$level";
    return unless $self->$is_level;

    my $log_any_context = {};
    if ((ref $log_args[-1]) eq 'HASH') {
        $log_any_context = pop @log_args;
    }

    my $stack_trace = _get_stack_trace(@log_args);
    my $log_message = join "\n" => @log_args;

    my $sentry_severity = $level;
    for ($sentry_severity) {
        s/trace/debug/ or
        s/notice/info/ or
        s/critical|alert|emergency/fatal/
    }

    my @message_args = (
        $log_message,
        level => $sentry_severity,
        tags  => $log_any_context,
    );

    if ($stack_trace) {
        push @message_args, Sentry::Raven->stacktrace_context($stack_trace);
    }

    # https://docs.sentry.io/data-management/event-grouping/
    $self->{sentry}->capture_message( @message_args );
}

for my $method ( Log::Any->detection_methods() ) {
    my $method_base = substr($method, 3); # chop of is_
    my $method_level = numeric_level($method_base);
    make_method(
        $method,
        sub { return $method_level <= $_[0]->{log_level} },
    );
}

sub _get_stack_trace {
    my @message_parts = @_;

    my $trace;
    if (@message_parts == 1) {
        $trace = extract_stack_trace($message_parts[0]);
    }
    unless (blessed($trace) && $trace->isa('Devel::StackTrace')) {
        $trace = Devel::StackTrace->new;
    }

    return $trace;
}

1;
