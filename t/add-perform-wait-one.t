package test;

use Test::More;
use Data::Dumper;

use Warteschlange::Queue;

my $queue = Warteschlange::Queue->new("/home/tobi/dev/warteschlange/t/workers");

$queue->enqueue('Testjobs::OneSecondJob');
my $pid = $queue->run($queue->next_pending_job());
$queue->wait_all();
ok(scalar @{$queue->list_unfinished()} == 0, 'after wait_all no tests are unfinished');

done_testing();
