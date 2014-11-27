package Warteschlange::Queue;

use strict;
use warnings;
use diagnostics;

use DBIx::Connector;
use Parallel::ForkManager;
use Module::Load qw(load);
use Module::Loaded qw(is_loaded);
use Storable qw(freeze);
use Data::Dumper;

use Warteschlange::Job;

use namespace::clean;

sub new {
    my $class = shift;
    
    my $self = bless {
        dbc => DBIx::Connector->new("dbi:SQLite:dbname=:memory:", "", ""),
        @_,
    }, $class;

    $self->{dbc}->run(fixup => sub {
        my $dbh = $_;
        $dbh->do("create table jobs(
            job_id INTEGER PRIMARY KEY AUTOINCREMENT,
            class TEXT NOT NULL,    /* job class */
            created TEXT NOT NULL,  /* unix time when job was created */
            finished TEXT,          /* unix time when job finished */
            started TEXT,           /* unix time when job started */
            input BLOB,             /* input data (blob) for the job */
            output BLOB             /* output data (blob) from the job */
        );");
    });

    return $self;
}

sub num_pending_jobs {
    my $self = shift;

    return $self->{dbc}->dbh->selectrow_array(
        "SELECT count(*) FROM jobs WHERE started IS NULL", {});
}

sub can_do {
    my ($self, $worker_class) = @_;

    if (!is_loaded($worker_class)) {
        load $worker_class;
        return is_loaded($worker_class);
    }

    return 1;
}

sub enqueue {
    my ($self, $class, @args) = @_;
    
    die "Unable to enqueue job with job class '$class' because I don't know how to process these jobs :-(\n" if not $self->can_do($class);
    
    $self->{dbc}->dbh->do("INSERT INTO jobs (class, created, input) VALUES (?, ?, ?);", {},
        $class, time(), freeze(\@args)
    );
    print "enqueued $class with args @args\n";
}

sub _create_list_of_jobs {
    my @jobs = map { Warteschlange::Job->new($_) } @_;

    return \@jobs;
}

sub _list_helper {
    my $self   = shift;
    my $sql    = shift;
    my @params = @_;

    my $jobs_raw = $self->{dbc}->dbh->selectall_hashref($sql, @params);

    return _create_list_of_jobs(values %$jobs_raw);
}

sub list_all {
    my $self = shift;
    return $self->_list_helper("SELECT * FROM jobs", 'job_id');
}

sub list_unstarted {
    my $self = shift;
    return $self->_list_helper("SELECT * FROM jobs WHERE started IS NULL", 'job_id');
}

sub next_pending_job {
    my $self = shift;

    my $job_raw = $self->{dbc}->dbh->selectrow_hashref(
        "SELECT * FROM jobs WHERE started IS NULL LIMIT 1");

    return if not $job_raw;
    return Warteschlange::Job->new($job_raw);
}

sub run_next_pending {
    my $self = shift;
    
    $self->run($self->next_pending_job());
}

sub run {
    my $self = shift;
    my $job = shift;
    
    return if not $job;
    
    $job->{started} = time();
    # fork here
    $job->{class}->work();
    $job->{finished} = time();
}

sub update_db {
    my $self = shift;
    my $job = shift;

    return $self->{dbc}->dbh->do(
        "UPDATE jobs SET finished=?, started=?, output=? WHERE job_id=?", {},
            $job->{finished}, $job->{started}, $job->{output}, $job->{id});
    
}

1;

