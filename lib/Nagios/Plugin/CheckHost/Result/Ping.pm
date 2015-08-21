package Nagios::Plugin::CheckHost::Result::Ping;

use strict;
use warnings;

use base "Nagios::Plugin::CheckHost::Result";

sub check_result {
    my $self = shift;

    my (@success, @fail);

    foreach my $node ($self->nodes) {
        if ($self->is_node_check_ok($node)) {
            push @success, $node;
        } else {
            push @fail, $node;
        }
    }

    return \@success, \@fail;
}

sub is_node_check_ok {
    my ($self, $node) = @_;

    my $failed_allowed = $self->{failed_allowed} || 0;
    my $result = $self->{results}->{$node};
    return unless $result;
    $result = $result->[0];
    return unless $result;
    return unless @$result;

    my ($success, $fail) = (0, 0);
    foreach my $check (@$result) {
        if (uc $check->[0] eq "OK") {
            $success++;
        } else {
            $fail++;
        }
    }
    
    my $total_fail = $fail/($fail+$success);

    $total_fail <= $failed_allowed;
}

1;
