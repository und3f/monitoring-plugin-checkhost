package Monitoring::Plugin::CheckHost::Result::Http;

use strict;
use warnings;

use base 'Monitoring::Plugin::CheckHost::Result';

sub request_ok {
    my ($self, $node) = @_;

    $self->{results}->{$node}->[0]->[0];
}

sub request_time {
    my ($self, $node) = @_;

    0+$self->{results}->{$node}->[0]->[1];
}

1;
