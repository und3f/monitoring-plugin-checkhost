#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use_ok "Net::CheckHost";

my $ch = new_ok 'Net::CheckHost';

my $request = $ch->prepare_request('check-ping', "localhost", {max_nodes => 3});
is $request->method, 'GET';
is $request->uri, 'https://check-host.net/check-ping?host=localhost&max_nodes=3';
is $request->header('Content-Type'), 'application/json';

done_testing();
