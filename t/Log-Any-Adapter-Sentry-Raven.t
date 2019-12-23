use strict;
use warnings;

use Test::More;

BEGIN { use_ok('Log::Any::Adapter::Sentry::Raven') };

diag(qq(Log::Any::Adapter::Sentry::Raven Perl $], $^X));

done_testing;
