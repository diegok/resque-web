use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use lib 't/lib';
use Test::SpawnRedisServer;

my ($c, $server) = redis();
END { $c->() if $c }


my $t = Test::Mojo->new('Resque::Web' => {redis => $server, namespace => 'test_resque_web'});

$t->app->log->level('error');

$t->get_ok('/ping')->status_is(200)->content_is('"PONG"', 'resque has a redis connection');

$t->get_ok('/stats')
    ->status_is(200)
    ->content_type_like(qr/json/)
    ->json_has('/redis', 'has redis stats')
    ->json_is('/processed', 0, 'processed count is zero');

$t->get_ok('/stats/resque')
    ->status_is(200)
    ->content_type_like(qr/json/)
    ->json_has('/redis', 'has redis stats')
    ->json_has('/processed', 'has processed count')
    ->json_has('/queues', 'has queues count')
    ->json_has('/workers', 'has workers count')
    ->json_has('/working', 'has workers count');

$t->get_ok('/queues')
    ->status_is(200)
    ->content_type_like(qr/json/)
    ->json_has('/items', 'has items')
    ->json_is('/failed', 0, 'there is not failed jobs');

$t->get_ok('/workers')
    ->status_is(200)
    ->content_type_like(qr/json/) ;

$t->get_ok('/failed')
    ->status_is(200)
    ->content_type_like(qr/json/)
    ->json_has('/items', 'has item list')
    ->json_is('/total', 0, 'total is zero');

$t->post_ok('/queues/test', json => { class => 'Test', args => [] }, "Push a job with JSON payload" )
    ->status_is(200);

$t->get_ok('/stats/resque')
    ->status_is(200)
    ->json_is('/pending', 1, 'stats shows one pending job');

done_testing();
