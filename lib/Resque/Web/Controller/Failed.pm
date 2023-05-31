package Resque::Web::Controller::Failed;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    my $args = $c->paged_params;
    Mojo::IOLoop->subprocess->run_p(sub {
        return (
            scalar($c->resque->failures->all($args->{start}, $args->{end})),
            $c->resque->failures->count
        );
    })->then(sub($items, $total) {
        $c->render( json => {
            items => $items,
            total => $total
        });
    });
};

sub empty($c) {
    Mojo::IOLoop->subprocess->run_p(sub {
        $c->resque->failures->clear;
    })->then(sub{
        $c->render( json => {} );
    });
};

sub mass_dequeue($c) {
    my $args = $c->req->json || $c->req->params->to_hash;
    Mojo::IOLoop->subprocess->run_p(sub {
        $c->resque->failures->mass_remove(%$args)
    })->then(sub($total) {
        $c->render( json => { total => $total });
    });
};

sub requeue_one($c) {
    Mojo::IOLoop->subprocess->run_p(sub {
        $c->resque->failures->requeue($c->stash('idx'));
    })->then(sub{
        $c->render( json => {} );
    });
};

sub remove_one($c) {
    Mojo::IOLoop->subprocess->run_p(sub {
        $c->resque->failures->remove($c->stash('idx'));
    })->then(sub{
        $c->render( json => {} );
    });
};

1;
