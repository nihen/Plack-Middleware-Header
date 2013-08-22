use strict;
use warnings;
use Test::More;
use HTTP::Request;
use HTTP::Message::PSGI;
use Plack::Builder;
use Plack::Test;

my @tests = (
    ['Content-Type' => 'text/csv']  => ['Content-Type' => 'text/plain'],
    [ ]                             => ['Content-Type' => 'text/plain'],
    ['Content-Type' => 'x-text/my'] => ['Content-Type' => 'text/plain'],
    ['Content-Type' => 'image/png'] => ['Content-Type' => 'image/png']
);

while (my ($has, $want) = splice @tests, 0, 2) {
    my $app = builder {
        enable 'Header',
            set  => ['Content-Type' => 'text/plain'],
            when => [
                'Content-Type' => qr{^text/}, 
                'Content-Type' => 'x-text/my',
                'Content-Type' => undef, 
            ];
        sub { ['200', $has, []] };
    };

    my $env = HTTP::Request->new(GET => '/')->to_psgi;
    my $res = $app->($env);
    is_deeply $res->[1], $want;
}

done_testing;
