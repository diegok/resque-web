package Resque::Web::Controller::Stats;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub ping($c) {
    eval { $c->render( json => $c->resque->redis->ping ) }
    || $c->render( json => 'ERROR', status => 503 );
};

sub basic($c) {
    Mojo::IOLoop->subprocess->run_p(sub {
        return {
            processed => $c->resque->worker->stat->get('processed'),
            redis     => $c->resque->redis->info,
        }
    })->then(sub($res){
        $c->render( json => $res );
    });
};

sub full($c) {
    Mojo::Promise->all(
        $c->queues_p,
        $c->workers_p,
        Mojo::IOLoop->subprocess->run_p(sub {
            return {
                processed => $c->resque->worker->stat->get('processed'),
                failed    => $c->resque->failures->count,
                redis     => $c->resque->redis->info,
            }
        })
    )->then(sub($queues, $workers, $info){
        $c->render( json => { $info->[0]->%*,
            pending => $queues->[0]->map(sub{$_->{'jobs'}})->reduce(sub{ $a + $b }),
            queues  => $queues->[0]->size,
            workers => $workers->[0]->size,
            working => $workers->[0]->grep(sub{ $_->{working}{state} eq 'working' })->size
        });
    });
};

1;
