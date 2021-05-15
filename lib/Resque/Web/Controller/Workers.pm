package Resque::Web::Controller::Workers;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($c) {
    $c->render( json => $c->workers->to_array )
}

1;
