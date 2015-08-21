package Nagios::Plugin::CheckHost::Result;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    
    my $nodes = delete $args{nodes} or die "Missed nodes information";
    my %nodes = map {$_->identifier => $_} @$nodes;
    bless {%args, nodes => \%nodes, results => {}}, $class;
}

sub store_result {
    my ($self, $results) = @_;
    foreach my $node (keys %$results) {
        my $node_c = $self->{nodes}{$node} or next;

        $self->{results}{$node_c} = $results->{$node};
    }
}

sub unfinished_nodes {
    my $self = shift;
    my @nodes;

    foreach my $node (values %{$self->{nodes}}) {
        push @nodes, $node unless exists $self->{results}{$node};
    }

    @nodes;
}

sub nodes {
    values %{$_[0]->{nodes}};
}

1;
