package WebService::Async::SmartyStreets::International;
$WebService::Async::SmartyStreets::International::VERSION = '0.001';
use strict;
use warnings;

use parent 'WebService::Async::SmartyStreets';


# =head2 _init

# Overrides _init from IO::Async::Notifier
# Takes in the following parameters (in hash):

# = over 4

# = item * C<country> - country
# = item * C<address1> - address line 1
# = item * C<address2> - address line 2
# = item * C<organization> - name of organization (usually building names)
# = item * C<locality> - city
# = item * C<administrative_area> - state
# = item * C<postal_code> - post code
# = item * C<geocode> - true or false

# = back 

# Returns a L<WebService::Async::SmartyStreets::International> instance.

# =cut

# sub _init {
#     my ($self, $paramref) = @_;
#     $self->SUPER::_init;
    
#     for my $each_input (qw(country address1 address2 organization locality administrative_area postal_code geocode)) {
#         $self->{address}->{$each_input} = delete $paramref->{$each_input} if exists $paramref->{$each_input};
#     }
# }

# =head2 get_address

# Overrides get_address in L<WebService::Async::SmartyStreets>
# Returns address in hash 

# =cut

# sub get_address : method { shift->{address} }

# =head2 get_url

# Overrides get_uri in l<WebService::Async::SmartyStreets>
# Returns URI in string  

# =cut

sub get_uri { return 'https://international-street.api.smartystreets.com/verify'; }

1;