package Resque::Web;
use Mojo::Base 'Mojolicious', -signatures;
use Mojo::File qw/ curfile /;
use Mojo::Collection qw/ c /;
use Mojo::Home;
use Resque;

our $VERSION = '0.1';

sub startup ($self) {
    $self->secrets(['sessionless']);
    $self->setup_plugins;
    $self->setup_helpers;
    $self->setup_routes;
}

sub setup_routes($self) {
    my $r = $self->routes;

    $r->get('/')->to('Front#init');

    $r->get('/ping')->to('Stats#ping');
    $r->get('/stats')->to('Stats#basic');
    $r->get('/stats/resque')->to('Stats#full');

    $r->get('/queues')->to('Queues#list');
    $r->get('/queues/:name')->to('Queues#show');
    $r->post('/queues/:name')->to('Queues#push_job');
    $r->delete('/queues/:name')->to('Queues#remove');

    $r->get('/workers')->to('Workers#list');

    $r->get('/failed')->to('Failed#list');
    $r->post('/failed')->to('Failed#mass_dequeue');
    $r->delete('/failed')->to('Failed#empty');
    $r->post('/failed/:idx')->to('Failed#requeue_one');
    $r->delete('/failed/:idx')->to('Failed#remove_one');
}

sub setup_plugins($self) {
    # Make this app installable (from cookbook)
    $self->home(Mojo::Home->new(curfile->sibling('Web')));
    $self->static->paths->[0]   = $self->home->child('public');
    $self->renderer->paths->[0] = $self->home->child('templates');
    #$self->commands->namespaces(['Mojolicious::Commands']);

    # Tests need to force a config, so skip loading a real one.
    return if $self->config->{config_override};

    my $file = c(qw(
        ~/.config/resque-web.conf
        ~/.config/resque-web/config
        ~/.resque-web.conf
        /etc/resque-web.conf
        /etc/resque-web/config
    ))->map(sub{ glob($_) })->first(sub{ -f $_ });

    $self->app->log->debug( $file ? "Loading config from $file" : 'No config file found' );

    $self->plugin('Config', {
        file => $file || $self->home->child('resque-web.conf')
    });
}

sub setup_helpers($self) {
    $self->helper( resque => sub($c){
        state $r = Resque->new( $c->app->config->%* );
    });

    $self->helper( paged_params => sub($c, $attr = {}){
        $attr->{page}  = $c->param('page')  || 1;
        $attr->{size}  = $c->param('size')  || 20;
        $attr->{start} = $c->param('start') || ($attr->{page} - 1) * $attr->{size};
        $attr->{end}   = $c->param('end')   || $attr->{start} + $attr->{size};
        $attr;
    });

    $self->helper( queues => sub($c){
        my $queues = $c->resque->queues;
        my $sizes  = $c->resque->size_map($queues);
        c( map {{ name => $_, jobs => $sizes->{$_} }} $queues->@* );
    });

    $self->helper( workers => sub($c){
        my @workers = $c->resque->worker->all->@*;
        my $work_at = $c->resque->worker->processing_map(@workers);
        c( map{{
                id      => $_->id,
                queues  => $_->queues,
                paused  => $_->paused,
                working => _working($_, $work_at->{$_->id})
            }} @workers
        );
    });
}

sub _working($worker, $job) {
    return { state => 'idle' } unless %$job;
    $job->{state}  = 'working';
    $job->{run_at} = $worker->processing_started($job)->stringify if $job->{run_at};
    $job;
}

1;
