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

    my $api = $r->under('/')->to( cb => sub($c){
        return 1 unless $c->req_is_human;
        $c->init_client;
        0;
    });

    $api->get('/ping')->to('Stats#ping');
    $api->get('/stats')->to('Stats#basic');
    $api->get('/stats/resque')->to('Stats#full');

    $api->get('/queues')->to('Queues#list');
    $api->get('/queues/:name')->to('Queues#show');
    $api->post('/queues/:name')->to('Queues#push_job');
    $api->delete('/queues/:name')->to('Queues#remove');

    $api->get('/workers')->to('Workers#list');

    $api->get('/failed')->to('Failed#list');
    $api->post('/failed')->to('Failed#mass_dequeue');
    $api->delete('/failed')->to('Failed#empty');
    $api->post('/failed/:idx')->to('Failed#requeue_one');
    $api->delete('/failed/:idx')->to('Failed#remove_one');

    $r->get('/')->to(cb => sub($c){
        $c->init_client;
    });
    $r->get('/*')->to(cb => sub($c){
        $c->init_client;
    });
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

    $self->helper( cached => sub($c, $key, $cb, $secs = 1){
        state $cache = {};
        my $now = time;

        $cache->{$key} = {
            t   => $now,
            res => $cb->($c)
        } unless ($cache->{$key}{t}||0) >= $now - $secs;

        $cache->{$key}{res};
    });

    $self->helper( queues => sub($c){
        $c->cached( queues => sub($c){
            $c->app->log->debug('queues');
            my $queues = $c->resque->queues;
            my $sizes  = $c->resque->size_map($queues);
            c( map {{ name => $_, jobs => $sizes->{$_} }} $queues->@* );
        });
    });

    $self->helper( workers => sub($c){
        $c->app->log->debug('workers');
        $c->cached( workers => sub($c){
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
    });

    $self->helper( req_is_human => sub($c) {
        return 0 if $c->req->is_xhr;
        return 0 if $c->req->headers->user_agent =~ /curl/i;
        return 0 if $c->req->headers->accept !~ /html/i;
        1;
    });

    $self->helper( init_client => sub($c) {
        state $client_app = $self->home->child('public', 'index.html');
        $c->reply->file($client_app);
    });
}

sub _working($worker, $job) {
    return { state => 'idle' } unless %$job;
    $job->{state}  = 'working';
    $job->{run_at} = $worker->processing_started($job)->stringify if $job->{run_at};
    $job;
}

1;
