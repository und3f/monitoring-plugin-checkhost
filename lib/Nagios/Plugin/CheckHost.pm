package Nagios::Plugin::CheckHost;

use strict;
use warnings;

our $VERSION = 0.01;
our $URL = 'https://check-host.net/';

use Net::CheckHost;
use Monitoring::Plugin;
use Class::Load qw(load_class);
use Nagios::Plugin::CheckHost::Node;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        checkhost    => Net::CheckHost->new(),
        delay        => 2,
        max_waittime => 30,
        %args,
    }, $class;

    $self->_initialize();
}

sub _initialize_nagios {
    my ($self, %args) = @_;

    $self->{nagios} = Monitoring::Plugin->new(
        shortname => 'CHECKHOST',
        usage     => 'Usage: %s -H <host> -w <warning> -c <critical>',
        url       => $URL,
        version   => $VERSION,
        %args
    );
}

sub nagios { $_[0]->{nagios} }

sub run {
    my $self = shift;
    my $np   = $self->{nagios};

    $np->getopts;
    my $opts      = $np->opts;
    my $host      = $opts->get('host');
    my $max_nodes = $opts->get('max_nodes');

    my $result = $self->_check(
        $self->{check}, $host,
        max_nodes   => $max_nodes,
    );
    $self->process_check_result($result);
}

sub _check {
    my ($self, $type, $host, %args) = @_;

    my $max_nodes = delete $args{max_nodes} || 3;
    my $max_failed_nodes = delete $args{max_failed_nodes} // 1;
    my $result_args = delete $args{result_args} || {};

    my $result;

    try {
        my $check = $self->{checkhost}
          ->request("check-$type", host => $host, max_nodes => $max_nodes);

        my $rid = $check->{request_id};
        $self->{request_id} = $rid;

        my $result_class =
          "Nagios::Plugin::CheckHost::Result::" . ucfirst($type);
        load_class($result_class);
        $result = $result_class->new(%$result_args,
            nodes => $self->nodes_class($check->{nodes}));

        my $start = time();
        do {
            sleep $self->{delay};
            $result->store_result(
                $self->{checkhost}->request("check-result/$rid"));
          } while ($start - time() < $self->{max_waittime}
            && $result->unfinished_nodes);
    }
    catch {
        $self->{nagios}->die($_);
    };

    return $result;
}

sub nodes_class {
    my ($self, $nodes_list) = @_;
    my @nodes =
      map { Nagios::Plugin::CheckHost::Node->new($_ => $nodes_list->{$_}) }
      keys %$nodes_list;
    \@nodes;
}

sub report_url {
    my $self = shift;

    $URL . "check-report/" . $self->{request_id};
}

1;
