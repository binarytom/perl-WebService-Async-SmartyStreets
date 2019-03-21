package WebService::Async::SmartyStreets::Address;

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

sub address_parts {
    my ($self) = @_;
    @{$self}{grep { exists $self->{$_} } map { 'address' . $_ } 1..12 }
}

=head2

Various subroutine that parses and returns the field from the caller

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

Checks if the returned response at least hits a certain level (in terms of score)

return type: 1 or 0

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

Similar with status at least, checks if the returned response at least hits a certain accuracy (in terms of score)
Instantly returns 0 if the status is lower than 'partial'

return type: 1 or 0

=cut

sub accuracy_at_least {
    my ($self, $target) = @_;
    return 0 unless $self->status_at_least('partial');
    my $target_level = $accuracy_level{$target} // die 'unknown target accuracy ' . $target;
    my $actual_level = $accuracy_level{$self->address_precision} // die 'unknown accuracy ' . $self->address_precision;
    return $actual_level >= $target_level;
}

1;

