use strict;
use warnings;
use Future;
use Test::More;
use Test::MockModule;
use WebService::Async::SmartyStreets;
use JSON::MaybeXS qw( encode_json );
use Future::AsyncAwait;

my $user_agent = Test::MockModule->new('Net::Async::HTTP');
$user_agent->mock(
    GET => sub {
        return Future->done();
    });

my $mock_ss = Test::MockModule->new('WebService::Async::SmartyStreets');
$mock_ss->mock(
    auth_id => sub {
        return 1;
    },
    
    token => sub {
        return 1;
    },
    
    get_decoded_data => sub{
        my $data = [{
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
            },
            }
        ];
        return Future->done($data);
    });

    
subtest "Call SmartyStreets" => sub {
    my $ss = WebService::Async::SmartyStreets->new(
        # this function is mocked, so the values doesnt matter
        auth_id => '...',
        token => '...'
    );
    
    my $addr = $ss->verify_international(
        address1            => 'Jalan 1223 Jamse Bndo 012',
        address2            => '03/03',
        locality            => 'Sukabumi',
        administrative_area => 'JB',
        postal_code         => '43145',
        country             => 'Indonesia',
        geocode             => 'true',
    )->get();

    # Check if status check is correct
    is ($addr->status_at_least('none'), 1, "Verification score is correct");
    is ($addr->status_at_least('verified'), '', "Verification score is correct");
    
    # Check if address accuracy level check is correct
    is ($addr->accuracy_at_least('locality'), 1, "Accuracy checking is correct");
    is ($addr->accuracy_at_least('delivery_point'), '', "Accuracy checking is correct");
    

};

done_testing();