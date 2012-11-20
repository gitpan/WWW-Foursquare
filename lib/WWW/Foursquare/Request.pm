package WWW::Foursquare::Request;

use strict;
use warnings;

our $VERSION = '0.9902';

use WWW::Foursquare::Config;
use WWW::Foursquare::Response;
use LWP::UserAgent;
use URI::Escape;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless $self, $class;
    $self->{access_token}  = $params->{access_token};
    $self->{client_id}     = $params->{client_id};
    $self->{client_secret} = $params->{client_secret};    
    $self->{debug}         = $params->{debug};
    $self->{GET}           = [];
    $self->{ua}            = LWP::UserAgent->new();

    return $self;
}

sub GET {
    my ($self, $path, $params) = @_;

    # add request to multi list
    return $self->MULTI('GET', $path, $params) if delete $params->{multi};
    my $is_show_request = 1 if delete $params->{show_request};

    # add auth params    
    $self->_add_auth_to_params($params);

    my $query      = $self->_params_to_str($params);
    my $result_url = sprintf "%s%s?%s", $API_ENDPOINT, $path, $query;

    # to check which url we prepared for request
    return $result_url if $is_show_request;
    warn $result_url   if $self->{debug};

    my $res = $self->{ua}->get($result_url);
    return $self->_response($res);
}

sub POST {
    my ($self, $path, $params) = @_;

    my $is_show_request = 1 if delete $params->{show_request};

    # add auth params    
    $self->_add_auth_to_params($params);

    my $query      = $self->_params_to_auth($params);
    my $result_url = sprintf "%s%s?%s", $API_ENDPOINT, $path, $query;

    # for testing url request
    return $result_url if $is_show_request;

    # convert hash to array (because of LWP)
    my @params  = map { $_ => $params->{$_} } keys %$params;
    warn $result_url if $self->{debug};

    my $res = $self->{ua}->post($result_url, Content_Type => 'form-data', Content => [ @params ]);
    return $self->_response($res);
}

sub MULTI {
    my ($self, $method, $path, $params) = @_;

    # internal type error
    return 'error' if ($method !~ /^GET|POST$/);    

    my $force = delete $params->{force};
    my $query = $self->_params_to_str($params);
    my $url   = $query 
              ? sprintf("/%s?%s", $path, $query)
              : sprintf("/%s", $path);

    push @{$self->{$method}}, $url;
 
    # send multi request
    if (@{ $self->{$method} } >= 5 || $force) {

        my $request = join ',', @{$self->{$method}}; 
        $params->{requests} = $request;
        delete $self->{$method};

        return $self->$method('multi', $params);
    }
    # put request to queue
    else {

        return scalar(@{ $self->{$method} });
    }
}

sub _response {
    my ($self, $res) = @_;

    return WWW::Foursquare::Response->new()->process($res);
}

sub _add_auth_to_params {
    my ($self, $params) = @_;

    if ($self->{userless}) {

        $params->{client_id}     = $self->{client_id};
        $params->{client_secret} = $self->{client_secret};
    }
    else {

        $params->{oauth_token} = $self->{access_token};
    }
    $params->{v} = $API_VERSION;
}

sub _params_to_str {
    my ($self, $params) = @_;

    my %copy_params = %$params;
    delete $copy_params{show_request};

    my $query = join '&', map { $_.'='.uri_escape($copy_params{$_}) } sort keys %copy_params;
    return $query;
}

sub _params_to_auth {
    my ($self, $params) = @_;

    my @auth = qw(client_id client_secret oauth_token v);
    my @exists;
    PARAM:
    for my $param (@auth) {
        
        next PARAM if not exists $params->{$param};
        push @exists, $param.'='.uri_escape($params->{$param});
    }
    my $query = join '&', @exists; 
    return $query;
}


1;
