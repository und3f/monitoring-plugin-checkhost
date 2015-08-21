package Nagios::Plugin::CheckHost;

use strict;
use warnings;

our $VERSION = 0.01;
use Net::CheckHost;
use Nagios::Plugin;
use Class::Load qw(load_class);
use Nagios::Plugin::CheckHost::Node;

sub new {
    my ($class, %args) = @_;

    bless {
        checkhost => Net::CheckHost->new(),
        delay => 2,
        max_waittime => 30,
        %args,
    }, $class;
}

sub check {
    my ($self, $type, $host, %args) = @_;
    
    my $max_nodes = $args{max_nodes} || 3;
    my $check = $self->{checkhost}->request("check-$type", host => $host, max_nodes => $max_nodes);
    my $rid = $check->{request_id};
    my $result_class = "Nagios::Plugin::CheckHost::Result::" . ucfirst($type);
    load_class($result_class);
    my $result = $result_class->new(nodes => $self->nodes_class($check->{nodes}));

    my $start = time();
    do {
        sleep $self->{delay};
        $result->store_result($self->{checkhost}->request("check-result/$rid"));
    }
    while ($start - time() < $self->{max_waittime}
        && $result->unfinished_nodes);

    $result->check_result;
}

sub nodes_class {
    my ($self, $nodes_list) = @_;
    my @nodes = map {Nagios::Plugin::CheckHost::Node->new($_ => $nodes_list->{$_})} keys %$nodes_list;
    \@nodes;
}

1;
