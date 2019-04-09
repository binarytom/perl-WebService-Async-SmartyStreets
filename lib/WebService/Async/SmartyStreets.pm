package WebService::Async::SmartyStreets;
# ABSTRACT: Access SmartyStreet API

use strict;
use warnings;

our $VERSION = '0.001';

=head1 NAME

WebService::Async::SmartyStreets - calls the SmartyStreets API and checks for the validity of the address

=head1 SYNOPSIS

    my $ss = WebService::Async::SmartyStreets->new(
        auth_id => #insert auth_id,
        token   => #insert token,
        api_choice => #international or us, default as 'international' if its undefined
        );
    IO::Async::Loop->new->add($ss);

    my $addr = $ss->verify(<list of address element>, geocode => 'true')->get;
    print($addr->status);

=head1 DESCRIPTION

This module calls the SmartyStreets API and parse the response to L<WebService::Async::SmartyStreets::Address>.

Note that this module uses L<Future::AsyncAwait>.

=cut

use parent qw(IO::Async::Notifier);

use mro;
no indirect;

use URI;
use URI::QueryParam;

use Future::AsyncAwait;
use Net::Async::HTTP;
use JSON::MaybeUTF8 qw(:v1);
use Syntax::Keyword::Try;

use WebService::Async::SmartyStreets::Address;

use Log::Any qw($log);

=head2 verify

Makes connection to SmartyStreets API and parses the response into WebService::Async::SmartyStreets::Address.

    my $addr = $ss->verify(%address_to_check)->get;

Takes the following named parameters:

=over 4

=item * C<country> - country [THIS FIELD IS COMPULSORY]

=item * C<address1> - address line 1

=item * C<address2> - address line 2

=item * C<organization> - name of organization (usually building names)

=item * C<locality> - city

=item * C<administrative_area> - state

=item * C<postal_code> - post code

=item * C<geocode> - true or false

=item * C<api_choice> - [NOTE] specifies which SmartyStreets API to call (by passing in this parameter, it would overide the one passed in config)

=back

Returns L<WebService::Async::SmartyStreets::Address> object

=cut

async sub verify {

    my ($self, %args) = @_;
    
    my %valid_api_choice = (
        international => 'https://international-street.api.smartystreets.com/verify',
        us            => 'https://us-street.api.smartystreets.com/street-address',
    );

    # provides the option to switch API token choice by overiding
    my $ss_api_choice = $args{api_choice} // $self->api_choice;

    # dies if the $api_choice is not valid
    die "Invalid API choice. Takes in 'international' and 'us' only." unless ($valid_api_choice{$ss_api_choice});
    
    my $uri = URI->new($valid_api_choice{$ss_api_choice});

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

=head2 Getters

The following subroutine returns the attributes respectively:

Example usage:

    $obj->auth_id;

=over 4

=item * C<auth_id>

=item * C<token>

=item * C<api_choice> - default as 'international' if its undefined

=back

=cut

sub auth_id { shift->{auth_id} }
sub token   { shift->{token} }
sub api_choice   { shift->{api_choice} // 'international' }

=head1 ===== INTERNAL METHODS =====

The following methods should only be used internally

=cut

=head2 get_decoded_data

Calls the SmartyStreets API then decode and parses the response give by SmartyStreets 

    my $decoded = await get_decoded_data($self, $uri)

Takes the following named parameters:

=over 4

=item * C<uri> - URI address that the process will make the call to

=back 

More information on the response can be seen in L<SmartyStreets Documentation | https://smartystreets.com/docs/cloud/international-street-api>

Returns an arrayref of hashrefs which the keys corresponds to L<WebService::Async::SmartyStreets::Address>

=cut

async sub get_decoded_data {
    my $self = shift;
    my $uri = shift;

    my $res;
    try {
        $res = await $self->ua->GET($uri);
    }
    catch {
        die "Unable to retrieve response.";
    };

    my $response = decode_json_utf8($res->decoded_content);

    return $response->[0];
}

=head2 configure

Configures the class with the auth_id and token

Takes the following named parameters:

=over 4

=item * C<auth_id> - auth_id obtained from SmartyStreet

=item * C<token> - token obtained from SmartyStreet

=item * C<api_choice> - specifies which SmartyStreet API to access

=back

=cut

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(auth_id token api_choice)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

sub next_id {
    ++(shift->{id} //= 'AA00000000');
}

=head2 ua

Accessor for the L<Net::Async::HTTP> instance which will be used for SmartyStreets API requests.

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

1;

