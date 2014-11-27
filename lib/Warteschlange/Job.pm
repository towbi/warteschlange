package Warteschlange::Job;

sub new {
    my $class = shift;
    my $args = shift;

    my $self = bless {
        dbc      => $args->{dbc},
        class    => $args->{class},
        created  => $args->{created},
        finished => $args->{finished},
        started  => $args->{started},
        input    => $args->{input},
        output   => $args->{output},
        id       => $args->{job_id},
    }, $class;

    return $self;
}

sub work {
    die "Don't call work() on this class.\n";
}

1;

