requires 'mro', 0;
requires 'indirect', 0;
requires 'parent', 0;
requires 'Net::Async::HTTP', '>= 0.44';
requires 'IO::Async::SSL', 0;
requires 'Future::AsyncAwait', '>= 0.21';

on configure => sub {
    requires 'ExtUtils::MakeMaker', '6.64';
};

on test => sub {
    requires 'Test::More';
    requires 'Test::Warn';
    requires 'Test::FailWarnings';
    requires 'Test::Fatal';
};