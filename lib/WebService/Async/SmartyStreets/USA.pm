package WebService::Async::SmartyStreets::USA;

use strict;
use warnings;

use parent 'WebService::Async::SmartyStreets';

=HEAD

WebService::Async::SmartyStreets::USA - calls the SmartyStreets US Street Address API and checks for the validity of the address

=head1 SYNOPSIS

    my $ss = WebService::Async::SmartyStreets::US->new(
        auth_id => #insert auth_id,
        token   => #insert token,
        );

=head1 DESCRIPTION

This module is the child module of L<WebService::Async::SmartyStreets>

This module specifically accesses the US Street Address API

For further information, please check L<WebService::Async::SmartyStreets> for more subroutines that can be accessed

=over 4

=cut

=head2 verify

Overrides verify in L<WebService::Async::SmartyStreets>

Gets the input arguments and pass it to the parents

    my $addr = $ss->verify(<list of address element>, geocode => 'true')->get;

Takes the following named parameters:

=over 4

=item * C<uri> - URI address (URL address to be pointed at)

=item * C<args> - address parameters in a list of keys and values (See L<WebService::Async::SmartyStreets/verify_international>)

=back

args consists of the following parameters:

=over 4

=item * C<country> - country

=item * C<address1> - address line 1

=item * C<address2> - address line 2

=item * C<organization> - name of organization (usually building names)

=item * C<locality> - city

=item * C<administrative_area> - state

=item * C<postal_code> - post code

=item * C<geocode> - true or false

=back 

Returns L<WebService::Async::SmartyStreets::Address> object

=cut

=cut

sub verify {
    my $self = shift;
    my $uri = 'https://us-street.api.smartystreets.com/street-address';
    my %args = @_;
    
    $self->SUPER::verify($uri, %args);
}

1;