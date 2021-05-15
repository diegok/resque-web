package Resque::Web::Controller::Queues;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    $c->render( json => {
        items  => $c->queues->to_array,
        failed => $c->resque->failures->count
    });
};

sub show($c) {
    my $name = $c->stash('name');
    my $args = $c->paged_params;
    $c->render( json => {
        jobs  => scalar($c->resque->peek($name, $args->{start}, $args->{end})),
        total => $c->resque->size($name)
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
