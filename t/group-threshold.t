#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Nagios::Plugin::Threshold;
use Nagios::Plugin::Functions qw(:all);
use_ok 'Nagios::Plugin::Threshold::Group';

my $SINGLE_CRITICAL = 4;
my $SINGLE_WARNING  = 2;
my $GROUP_CRITICAL  = 3;
my $GROUP_WARNING   = 1;

my $single_threshold = Nagios::Plugin::Threshold->new(
    critical => $SINGLE_CRITICAL,
    warning  => $SINGLE_WARNING,
);

my $group_threshold = Nagios::Plugin::Threshold->new(
    critical => $GROUP_CRITICAL,
    warning  => $GROUP_WARNING,
);

subtest 'everything is ok if every value just in range' => sub {
    my $gt = new_ok 'Nagios::Plugin::Threshold::Group', [
        single_threshold => $single_threshold,
        group_threshold  => $group_threshold,
    ];

    is $gt->add_value($SINGLE_WARNING + 1), WARNING,
      "Just one warning, it is allowed for OK";

    is($gt->add_value($SINGLE_WARNING), OK, "And a lot of OK values")
      for 1 .. $GROUP_CRITICAL;

    is $gt->get_status(), OK, 'ok status';
};

subtest 'we may got warning if we got '
  . 'critical + warning > group_warning' => sub {
    my $gt = new_ok 'Nagios::Plugin::Threshold::Group', [
        single_threshold => $single_threshold,
        group_threshold  => $group_threshold,
    ];

    # Recipe for a warning:
    # make single warning
    $gt->add_value($SINGLE_WARNING+1);

    # add critical for a taste
    $gt->add_value($SINGLE_CRITICAL+1);

    # and some OKs
    $gt->add_value($SINGLE_WARNING) for 1 .. 2;

    is $gt->get_status(), WARNING, 'warning status';
};

subtest 'you have to be critical to make it critical' => sub {
    my $gt = new_ok 'Nagios::Plugin::Threshold::Group', [
        single_threshold => $single_threshold,
        group_threshold  => $group_threshold,
    ];


    $gt->add_value($SINGLE_CRITICAL+1) for 1..$GROUP_CRITICAL;

    # Just a warning to prove that warning do not cause critical
    $gt->add_value($SINGLE_WARNING+1);
    is $gt->get_status(), WARNING, 'not a critical, yet..';

    $gt->add_value($SINGLE_CRITICAL + 1);
    is $gt->get_status(), CRITICAL, 'we been critical and it is critical now';
};

done_testing();
