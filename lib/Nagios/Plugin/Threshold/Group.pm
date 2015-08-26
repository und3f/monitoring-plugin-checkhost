package Nagios::Plugin::Threshold::Group;

use strict;
use warnings;

use Nagios::Plugin::Functions qw(OK WARNING CRITICAL);

sub new {
    my ($class, %args) = @_;

    my $single_threshold = delete $args{single_threshold};
    my $group_threshold  = delete $args{group_threshold};

    bless {
        single_threshold => $single_threshold,
        group_threshold  => $group_threshold,
        statuses => {
            Nagios::Plugin::Functions::OK       => 0,
            Nagios::Plugin::Functions::WARNING  => 0,
            Nagios::Plugin::Functions::CRITICAL => 0
          },
    }, $class;
}

sub add_value {
    my ($self, $value) = @_;

    my $status = $self->{single_threshold}->get_status($value);
    $self->{statuses}->{$status}++;

    $status;
}

sub get_status {
    my $self = shift;

    my $t = $self->{group_threshold};
    my $s = $self->{statuses};
    my $criticals = $s->{Nagios::Plugin::Functions::CRITICAL};
    my $status = $t->get_status($criticals);
    return $status if $status != OK;

    if ($t->warning->is_set) {
        my $warnings = $s->{Nagios::Plugin::Functions::WARNING};
        return WARNING if $t->warning->check_range($warnings + $criticals);
    }

    OK
}

1;
