package WebService::Async::SmartyStreets::Address;

use strict;
use warnings;

=head1

WebService::Async::SmartyStreets::Address - object that contains the response from SmartyStreets API 

=head1 SYNOPSIS

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

Represents (parses) the return response from SmartyStreets API in an object

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

=cut

sub new {
    my ($class, %args) = @_;
    bless \%args, $class
}

=head2 Getters

The following subroutine returns each attributes respectively:
    
Example usage:
    
    $obj->input_id;

=over 4

=item * C<input_id>

=item * C<organization>

=item * C<latitude>

=item * C<longitude>

=item * C<geocode_precision>

=item * C<max_geocode_precision>

=item * C<address_format>

=item * C<status>

=item * C<address_precision>

=item * C<max_address_precision>

=back 

=cut

sub input_id { shift->{input_id} }

sub organization { shift->{organization} }

sub latitude { shift->{metadata}{latitude} }

sub longitude { shift->{metadata}{longitude} }

sub geocode_precision { shift->{metadata}{geocode_precision} }

sub max_geocode_precision { shift->{metadata}{max_geocode_precision} }

sub address_format { shift->{metadata}{address_format} }

sub status { lc shift->{analysis}{verification_status} // ''}

sub address_precision { lc shift->{analysis}{address_precision} // ''}

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

