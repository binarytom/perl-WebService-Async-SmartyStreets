package WebService::Async::SmartyStreets;
# ABSTRACT: Access SmartyStreet API

use strict;
use warnings;

our $VERSION = '0.001';

=HEAD

WebService::Async::SmartyStreets - calls the SmartyStreets API and checks for the validity of the address

=head1 VERSION

version 0.001

=head1 SYNOPSIS
    
    my $loop = IO::Async::Loop->new;
    $loop->add(
        my $ss = WebService::Async::SmartyStreets->new(
            # International token
            auth_id => '...'
            token => '...'
        )
    );
    (async sub {
        my $addr = await $ss->verify_international(
            # insert address here
        );
    })->()->get;
    
=head1 DESCRIPTION

his class calls the SmartyStreets API and parse the response to `WebService::Async::SmartyStreets::Address`

=over 4

=cut

use parent qw(IO::Async::Notifier);

use mro;
no indirect;

use URI;
use URI::QueryParam;

use Future::AsyncAwait;
use Net::Async::HTTP;
use JSON::MaybeUTF8 qw(:v1);

use WebService::Async::SmartyStreets::Address;

use Log::Any qw($log);

=head2 configure

Configures the class with the auth_id and token
Takes in: Hash of auth_id and token

=cut

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(auth_id token)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

sub auth_id { shift->{auth_id} }
sub token   { shift->{token} }

sub next_id {
    ++(shift->{id} //= 'AA00000000');
}

=head2 ua

Creates a User agent (Net::Async::HTTP) that is used to make connection to the SmartyStreets API

=cut

sub ua {
    my ($self) = @_;
    $self->{ua} //= do {
        $self->add_child(
            my $ua = Net::Async::HTTP->new(
                fail_on_error            => 1,
                decode_content           => 1,
                pipeline                 => 0,
                max_connections_per_host => 4,
                user_agent =>
                    'Mozilla/4.0 (WebService::Async::SmartyStreets; BINARY@cpan.org; https://metacpan.org/pod/WebService::Async::SmartyStreets)',
            ));
        $ua;
        }
}

=head2 verify_international, verify_usa

Calls to different API depending on the country of the address.
Takes in: Hash of address and required components
Returns: WebService::Async::SmartyStreets::Address object

=cut

async sub verify_international {
    my ($self, %args) = @_;
    my $uri = URI->new('https://international-street.api.smartystreets.com/verify');
    return await $self->verify($uri => %args);
}
async sub verify_usa {
    my ($self, %args) = @_;
    my $uri = URI->new('https://us-street.api.smartystreets.com/street-address');
    return await $self->verify($uri => %args);
}


=head2 verify

Makes connection to SmartyStreets API and parses the response into WebService::Async::SmartyStreets::Address.
Takes in: URI and hash
Returns: WebService::Async::SmartyStreets::Address object

=cut

async sub verify {
    my ($self, $uri, %args) = @_;
    $uri->query_param($_ => $args{$_}) for keys %args;
    $uri->query_param(
        'auth-id' => ($self->auth_id // die 'need an auth ID'),
    );
    $uri->query_param(
        'auth-token' => ($self->token // die 'need an auth token'),
    );
    $uri->query_param(
        'input-id' => $self->next_id,
    );
    $log->tracef('GET %s', '' . $uri);
    my $decoded = await get_decoded_data($self, $uri);
    $log->tracef('=> %s', $decoded);
    return map { WebService::Async::SmartyStreets::Address->new(%$_) } @$decoded;
}

=head2 get_decoded_data

Calls the SmartyStreets API then decode and return response
Takes in: Uri
Returns: decoded response in Hash

=cut

async sub get_decoded_data {
    my $self = shift;
    my $uri = shift;
    my $response = do {
        my $res = await $self->ua->GET($uri);
        decode_json_utf8($res->decoded_content);
    };
    return $response;
}

1;

