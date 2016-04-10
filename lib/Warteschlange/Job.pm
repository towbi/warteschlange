package Warteschlange::Job;

use Data::Dumper;
use Storable qw(thaw);

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
        pid      => $args->{pid},
    }, $class;

    return $self;
}

sub invoke_work {
    my $self = shift;

    $self->{started} = time();
    $self->update_db();
    $self->{class}->work(@{thaw($self->{input})});
    $self->{finished} = time();
    $self->update_db();
}

sub update_db {
    my $self = shift;

    return $self->{dbc}->dbh->do(
        "UPDATE jobs SET finished=?, started=?, output=? WHERE job_id=?", {},
            $self->{finished}, $self->{started}, $self->{output}, $self->{id});
}

1;

