package Resque::Web::Controller::Workers;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    $c->workers_p->then(sub($workers){
        $c->render( json => $workers->to_array )
    })
}

1;
