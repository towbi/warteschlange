package Testjobs::OneSecondJob;

use parent 'Warteschlange::Job';

sub work {
    sleep(1);
}

1;
