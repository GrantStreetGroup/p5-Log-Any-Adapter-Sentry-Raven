requires 'Log::Any::Adapter::Base';
requires 'Log::Any::Adapter::Util';
requires 'Sentry::Raven';

on develop => sub {
    requires 'Dist::Zilla::PluginBundle::Author::GSG';
};
