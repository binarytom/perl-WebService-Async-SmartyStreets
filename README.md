# NAME

WebService::Async::SmartyStreets::Address - parses the response from SmartyStreets API

# VERSION

version 0.001

# SYNOPSIS

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
    
# DESCRIPTION

This module parses the response by SmartyStreets API into an object to access them.

## Construction

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

## Sample SmartyStreets API response

    [
      {
        "address1": "Hainichener Str. 64",
        "address2": "09599 Freiberg",
        "components": {
          "administrative_area": "Sachsen",
          "sub_administrative_area": "Früher: Direktionsbezirk Chemnitz",
          "country_iso_3": "DEU",
          "locality": "Freiberg",
          "postal_code": "09599",
          "postal_code_short": "09599",
          "premise": "64",
          "premise_number": "64",
          "thoroughfare": "Hainichener Str.",
          "thoroughfare_name": "Hainichenerstr.",
          "thoroughfare_trailing_type": "Str."
        },
        "metadata": {
          "latitude": 50.92221,
          "longitude": 13.32259,
          "geocode_precision": "Premise",
          "max_geocode_precision": "DeliveryPoint",
          "address_format": "thoroughfare premise|postal_code locality"
        },
        "analysis": {
          "verification_status": "Verified",
          "address_precision": "Premise",
          "max_address_precision": "DeliveryPoint"
        }
      }
    ]

# Attributes

All attributes that is parsed includes:

- input_id
- organization
- latitude 
- longitude
- geocode_precision 
- max_geocode_precision
- address_format 
- verification_status 
- address_precision 
- max_address_precision

For more information about the attributes, click [here](https://smartystreets.com/docs/cloud/international-street-api)

# Methods

## status_at_least

Checks if the returned response at least hits a certain level (in terms of score).

## accuracy_at_least

Checks if the returned response at least hits a certain accuracy (in terms of score).
Instantly returns 0 if the status is lower than 'partial'.

# Attributes

## input_id

Returns the input_id parsed.

## organization

Returns the organization parsed.

## latitude 

Returns the latitude parsed.

## longitude

Returns the latitude parsed.

## geocode_precision 

Returns the geocode_precision parsed.

## max_geocode_precision

Returns the max_geocode_precision parsed.

## address_format 

Returns the value of address_format parsed.

## status 

Returns the value of verification_status parsed.

The value returned should be either:

- none
- ambiguous
- partial
- verified

## address_precision 

Returns the value of address_precision parsed.

## max_address_precision

Returns the value of max_address_precision parsed.

---

# NAME

WebService::Async::SmartyStreets;

# SYNOPSIS

    my $loop = IO::Async::Loop->new;
    $loop->add(
        my $ss = WebService::Async::SmartyStreets->new(
            # International token
            auth_id => '...',
            token => '...',
            api_choice => '...',
        )
    );
    async sub {
        my $addr = await $ss->verify(
            # insert address here
        );
    }->get;
    
# DESCRIPTION

This class calls the SmartyStreets API and parse the response to `WebService::Async::SmartyStreets::Address`

# METHODS

## verify

Makes connection to SmartyStreets API and parses the response into `WebService::Async::SmartyStreets::Address`.

Takes the following named parameters:
- args - address parameters in hash (See `WebService::Async::SmartyStreets/verify_international`)

args consists of the following parameters:

- country - country _[COMPULSORY]_
- address1 - address line 1
- address2 - address line 2
- organization - name of organization (usually building names)
- locality - city
- administrative_area - state
- postal_code - post code
- geocode - true or false
- api\_choice - _[OPTIONAL]_ will overide the api_choice in config

## get_decoded_data

Parses the response give by SmartyStreets 

More information of the resposne can be seen in [SmartyStreets Documentation](https://smartystreets.com/docs/cloud/international-street-api)

Returns an arrayref of hashrefs which the keys corresponds to `WebService::Async::SmartyStreets::Address`

## configure

configures the class with auth_id and token.

## auth_id

Returns auth_id.

## token

Returns token.

## api_choice

Returns api_choice.

## ua

Accessor for the `Net::Async::HTTP` instance which will be used for SmartyStreets API requests.

# AUTHOR

Binary.com

