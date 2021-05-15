package Resque::Web::Controller::Front;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub init($self) {
    $self->render( msg => 'This should be a Vue app' );
}

1;
