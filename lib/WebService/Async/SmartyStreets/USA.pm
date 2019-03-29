package WebService::Async::SmartyStreets::USA;

use strict;
use warnings;

use parent 'WebService::Async::SmartyStreets';

=head2 get_uri

Overrides get_uri in l<WebService::Async::SmartyStreets>
Returns URI in string  

=cut

sub get_uri { return 'https://us-street.api.smartystreets.com/street-address'; }

=head2 verify

Overrides verify in l<WebService::Async::SmartyStreets>
Gets the input arguments and pass it to the parents

=cut

sub verify {
    my $self = shift;
    my $uri = get_uri();
    my %args = @_;
    
    $self->SUPER::verify($uri, %args);
}

1;