package Warteschlange::Queue;

use Modern::Perl;
use DBI;
use File::Temp qw(mktemp);

use Moo;
use namespace::clean;

has _dbfile => (is => 'rw');
has _dbh    => (is => 'rw');

my $table = 'jobs';

use constant SCHEMA => <<EOT;
create table jobs(
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    created TEXT NOT NULL,  /* unix time when job started */
    finished TEXT NOT NULL, /* unix time when job finished */
    started INTEGER,        /* flag whether job has been started */
    completed INTEGER,      /* flag whether job has finished */
    input BLOB,             /* input data (blob) for the job */
    output BLOB,            /* output data (blob) from the job */
);
EOT

sub BUILD {
    my $self = shift;

    $self->_dbfile(mktemp("warteschlange-XXXXXXXXX"));

    $self->_dbh(DBI->connect("dbi:SQLite:dbname=".$self->_dbfile, "", ""));
}

sub num_pending_jobs {
    my $self = shift;
    
    return $self->_dbh->selectrow_array(
        "SELECT count(*) FROM $table WHERE finished=? AND started=?", 0, 0);
}

sub next_pending_job {
    return;
}

1;

