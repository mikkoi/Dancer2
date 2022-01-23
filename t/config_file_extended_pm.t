use strict;
use warnings;

use Test::More;
use File::Spec;

BEGIN {
    # undefine ENV vars used as defaults for app environment in these tests
    local $ENV{DANCER_ENVIRONMENT};
    local $ENV{PLACK_ENV};
}
use lib '.';
use lib './t/lib';

use Dancer2::ConfigReader::FileExtended;

my $location = '.';
my $environment = 'production';

my $fe = Dancer2::ConfigReader::FileExtended->new(
            location => $location,
            environment => $environment,
            );

is $fe->environment, $environment, 'Built right (env)';
is $fe->name, 'FileExtended', 'Built right (name)';

done_testing;
