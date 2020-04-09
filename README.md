# NAME

Log::Any::Adapter::Sentry::Raven - Log::Any::Adapter for Sentry::Raven

# VERSION

version v0.0.3

# DESCRIPTION

This is a backend to [Log::Any](https://metacpan.org/pod/Log::Any) for [Sentry::Raven](https://metacpan.org/pod/Sentry::Raven).

When logging, it does its best to provide a [Devel::StackTrace](https://metacpan.org/pod/Devel::StackTrace) to
identify your message. To accomplish this, it uses [Devel::StackTrace::Extract](https://metacpan.org/pod/Devel::StackTrace::Extract)
to pull a trace from your message (if you pass multiple message arguments, it
won't attempt this).
Failing that, it will append a new `Devel::StackTrace`.

It takes two arguments:

- sentry (REQUIRED)

    An instantiated [Sentry::Raven](https://metacpan.org/pod/Sentry::Raven) object.
    Note that if you set any sentry-specific context directly through the sentry
    object, it will be picked up here eg.

        $sentry->add_context( Sentry::Raven->request_context($url, %p) )

- log\_level (OPTIONAL)

    The minimum log\_level to log. Defaults to `trace` (everything).

Any ["Log context data" in Log::Any](https://metacpan.org/pod/Log::Any#Log-context-data) will be sent to Sentry as tags.

# SYNPOSIS

    use Log::Any::Adapter;
    Log::Any::Adapter->set('Sentry::Raven',
        sentry => Sentry::Raven->new(
            sentry_dsn  => $dsn,
            environment => 'production',
            ...
        )
    );

# SEE ALSO

[Log::Any](https://metacpan.org/pod/Log::Any), [Sentry::Raven](https://metacpan.org/pod/Sentry::Raven)

# AUTHOR

Grant Street Group &lt;developers@grantstreet.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 - 2020 by Grant Street Group.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
