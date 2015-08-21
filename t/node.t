#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use_ok 'Nagios::Plugin::CheckHost::Node';
my $node = new_ok 'Nagios::Plugin::CheckHost::Node',
  ['7f000001', ['be', 'Antwerp']];

is $node->identifier, '7f000001';
is $node->country, 'be';
is $node->city, 'Antwerp';

done_testing();
