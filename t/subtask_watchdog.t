use Mojo::Base -strict, -signatures;

use Test::More;
use Test::Mojo;
use Mojo::IOLoop;

# Fast watchdog so the test doesn't wait the production default.
local $ENV{RESQUE_WEB_SUBTASK_TIMEOUT} = 1;

my $t = Test::Mojo->new( 'Resque::Web', { config_override => 1 } );
my $c = $t->app->build_controller;

# A child wedged in a tight CPU loop, as seen in production: it never returns
# and inherits signal handlers, so only the watchdog's SIGKILL can reap it.
# The helper must settle anyway (catch returns the last known result) instead
# of pinning the key forever.
my $start = time;
my $res;
$c->single_subtask( wedge => sub($c) { 1 while 1 } )->then(sub($last) {
    $res = $last;
})->finally(sub {
    Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;

ok defined $res, 'wedged sub-task settled instead of hanging';
is_deeply $res, [], 'settled with the last known (empty) result';
cmp_ok time - $start, '<', 10, 'watchdog killed the child shortly after the timeout';

# The key must be released: a fresh run on the same key completes normally.
my $again;
$c->single_subtask( wedge => sub($c) { 'recovered' } )->then(sub($last) {
    $again = $last;
})->finally(sub {
    Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;

is_deeply $again, ['recovered'], 'key released after the kill; next run succeeds';

done_testing;
