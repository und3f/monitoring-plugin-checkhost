#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Nagios::Plugin::CheckHost::Node;

use_ok 'Nagios::Plugin::CheckHost::Result::Ping';

my $nodes = [
    Nagios::Plugin::CheckHost::Node->new("7f000001", ['be', 'Antwerp']),
    Nagios::Plugin::CheckHost::Node->new("7f000002", ['fr', 'Paris']),
    Nagios::Plugin::CheckHost::Node->new("7f000003", ['it', 'Milan']),
];

subtest "ping result" => sub {
    my $pingr = new_ok 'Nagios::Plugin::CheckHost::Result::Ping',
      [nodes => $nodes, failed_allowed => 0.5];
    is scalar $pingr->nodes, 3;
    $pingr->store_result({
            '7f000001' => [[["OK", 1, "127.0.0.1"], ["OK",      1]]],
            '7f000003' => [[["OK", 1, "127.0.0.1"], ["TIMEOUT", 5]]]
        }
    );
    is_deeply [$pingr->unfinished_nodes], [$nodes->[1]];

    $pingr->store_result({'7f000002' => [[]]});
    is_deeply [$pingr->unfinished_nodes], [];
    
    is $pingr->calc_loss($nodes->[0]), 0;
    is $pingr->calc_loss($nodes->[1]), 1;
    is $pingr->calc_loss($nodes->[2]), 0.5;
};

done_testing();
