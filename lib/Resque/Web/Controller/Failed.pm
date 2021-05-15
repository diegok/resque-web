package Resque::Web::Controller::Failed;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    my $args = $c->paged_params;
    $c->render( json => {
        items => scalar($c->resque->failures->all($args->{start}, $args->{end})),
        total => $c->resque->failures->count
    });
};

sub empty($c) {
    $c->resque->failures->clear;
    $c->render( json => {} );
};

#TODO: this can take looong so it's a good candidate for a sub-proc
sub mass_dequeue($c) {
    my $args = $c->req->json || $c->req->params->to_hash;
    $c->render( json => { total => $c->resque->failures->mass_remove(%$args) } );
};

sub requeue_one($c) {
    $c->resque->failures->requeue($c->stash('idx'));
    $c->render( json => {} );
};

sub remove_one($c) {
    $c->resque->failures->remove($c->stash('idx'));
    $c->render( json => {} );
};

1;
