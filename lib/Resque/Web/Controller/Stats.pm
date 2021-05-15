package Resque::Web::Controller::Stats;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub ping($c) {
    eval { $c->render( json => $c->resque->redis->ping ) }
    || $c->render( json => 'ERROR', status => 503 );
};

sub basic($c) {
    $c->render( json => {
        processed => $c->resque->worker->stat->get('processed'),
        redis     => $c->resque->redis->info,
    });
};

sub full($c) {
    my $queues  = $c->queues();
    my $workers = $c->workers();
    $c->render( json => {
        processed => $c->resque->worker->stat->get('processed'),
        failed    => $c->resque->failures->count,
        pending   => $queues->map(sub{$_->{'jobs'}})->reduce(sub{ $a + $b }),
        queues    => $queues->size,
        redis     => $c->resque->redis->info,
        workers   => $workers->size,
        working   => $workers->grep(sub{ $_->{working}{state} eq 'working' })->size
    });
};

1;
