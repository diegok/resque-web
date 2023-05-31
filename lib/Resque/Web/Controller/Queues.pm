package Resque::Web::Controller::Queues;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    Mojo::Promise->all($c->queues_p, $c->fail_count_p)->then(sub($queues, $fail_count){
        $c->render( json => {
            items  => $queues->[0]->to_array,
            failed => $fail_count->[0]
        });
    });
};

sub fail_count_p($c) {
    $c->single_subtask( fail_count => sub($c) {
        $c->resque->failures->count
    })->then(sub($res) {
        $res->[0] || 0
    });
}

sub show($c) {
    my $name = $c->stash('name');
    my $args = $c->paged_params;

    Mojo::IOLoop->subprocess->run_p(sub {
        my $jobs = [
            map { $_->payload } $c->resque->peek( $name, $args->{start}, $args->{end} )
        ];
        return $jobs, $c->resque->size($name);
    })->then(sub($jobs, $total) {
        $c->render( json => {
            jobs  => $jobs,
            total => $total
        });
    });
};

sub remove($c) {
    $c->resque->remove_queue($c->stash('name'));
    $c->render( json => {} );
};

sub push_job($c) {
    my $queue = $c->stash('name');
    my $args  = $c->req->json || $c->req->params->to_hash;

    eval { $c->resque->push( $queue => $args ) };
    return $c->render( json => { error => $@ }, status => 400 ) if $@;

    $c->render( json => {} );
};

1;
