# perl-WebService-Async-SmartyStreets

Address lookup and verification API

This repo makes the connection to [SmartyStreets](https://smartystreets.com/) 

## Description ##
The main purpose of the module is to predict the validity of a given address.
The module accepts multiple fields of an address, pass it to the SmartyStreets 
API and returns the predicted response. 

It will return a `Future WebService::Async::SmartyStreets::Address` object.

**More information about the API can be
found [here](https://smartystreets.com/docs/cloud/international-street-api).**

## Sample Usage ##

```
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
        address1            => 'Jl.pelabuhan 2 gang langgeng jaya 2 no 22',
        address2            => '03/03',
        locality            => 'Sukabumi',
        administrative_area => 'JB',
        postal_code         => '43145',
        country             => 'Indonesia',
        # Need to pass this if you want to do verification
        geocode             => 'true',
    );
})->()->get;
```

The module requires `auth_id` and `token` to run. The module offers `verify_international`
and `verify_usa`. The compulsary field is `country`.

The response is parsed and stored as `WebService::Async::SmartyStreets::Address` object.

The fields available are:

- input_id
- organization
- latitude 
- longitude
- geocode_precision 
- max_geocode_precision
- address_format 
- status 
- address_precision 
- max_address_precision