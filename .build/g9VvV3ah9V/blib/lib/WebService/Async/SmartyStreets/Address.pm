package WebService::Async::SmartyStreets::Address;
$WebService::Async::SmartyStreets::Address::VERSION = '0.001';
use strict;
use warnings;

=HEAD

WebService::Async::SmartyStreets::Address - object that contains the response from SmartyStreets API 

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use WebService::Async::SmartyStreets::Address;
    # Mocking a simple response from SmartyStreets API and parses it with WebService::Async::SmartyStreets::Address
    my $response = WebService::Async::SmartyStreets::Address->new(
            metadata => {
            latitude => 101.2131,
            longitude => 180.1223,
            geocode_precision => "Premise",
        },
        analysis => {
            verification_status => "Partial",
            address_precision => "Premise",
        });
    # Accessing the attributes
    print ($response->status);
    
=head1 DESCRIPTION

represents (parses) the return response from SmartyStreets API in an object

=head2 Construction
    
    WebService::Async::SmartyStreets::Address->new(
        input_id => 12345,
        organization => 'Beenary',
        metadata => {
            latitude => 101.2131,
            longitude => 180.1223,
            geocode_precision => "Premise",
        },
        analysis => {
            verification_status => "Partial",
            address_precision => "Premise",
        });
        
=over 4

=cut

sub new {
    my ($class, %args) = @_;
    bless \%args, $class
}

=head2 input_id

Returns the value of the input_id

Example usage:

    $obj->input_id;

=cut

sub input_id { shift->{input_id} }

=head2 organization

Returns the value of the organization

=cut

sub organization { shift->{organization} }

=head2 latitude

Returns the value of the latitude

=cut

sub latitude { shift->{metadata}{latitude} }

=head2 longitude

Returns the value of the longitude

=cut

sub longitude { shift->{metadata}{longitude} }

=head2 geocode_precision

Returns the value of the geocode_precision

=cut

sub geocode_precision { shift->{metadata}{geocode_precision} }

=head2 max_geocode_precision

Returns the value of the max_geocode_precision

=cut

sub max_geocode_precision { shift->{metadata}{max_geocode_precision} }

=head2 address_format

Returns the value of the address_format

=cut

sub address_format { shift->{metadata}{address_format} }

=head2 status

Returns the value of the status

=cut

sub status { lc shift->{analysis}{verification_status} // ''}

=head2 address_precision

Returns the value of the address_precision

=cut

sub address_precision { lc shift->{analysis}{address_precision} // ''}

=head2 max_address_precision

Returns the value of the max_address_precision

=cut

sub max_address_precision { lc shift->{analysis}{max_address_precision} // ''}

# Maps each verification response into a score
my %status_level = (
    none => 0,
    partial => 1,
    ambiguous => 2,
    verified => 3
);

=head2 status_at_least

Checks if the returned response  at least hits a certain level (in terms of score)

Example Usage:

    $obj->status_at_least("partial");

Takes L<String> which consists of verification status ("verified", "partial", "ambiguous", "none")

Returns 1 or 0

=cut

sub status_at_least {
    my ($self, $target) = @_;
    my $target_level = $status_level{$target} // die 'unknown target status ' . $target;
    my $actual_level = $status_level{$self->status} // die 'unknown status ' . $self->status;
    return $actual_level >= $target_level;
}

my %accuracy_level = (
    none => 0,
    administrative_area => 1,
    locality => 2,
    thoroughfare => 3,
    premise => 4,
    delivery_point => 5,
);

=pod

accuracy_at_least

Similar with status at least, checks if the returned response is at least hits a certain accuracy (in terms of score)

Example Usage:

    $obj->accuracy_at_least("premise");

Takes L<String> which consists of address accuracy ("none", "administrative_area", "locality", "thoroughfare", "premise", "delivery_point")

Returns 0 if the status is lower than 'partial'
Returns 1 or 0

=cut

sub accuracy_at_least {
    my ($self, $target) = @_;
    return 0 unless $self->status_at_least('partial');
    my $target_level = $accuracy_level{$target} // die 'unknown target accuracy ' . $target;
    my $actual_level = $accuracy_level{$self->address_precision} // die 'unknown accuracy ' . $self->address_precision;
    return $actual_level >= $target_level;
}

1;

