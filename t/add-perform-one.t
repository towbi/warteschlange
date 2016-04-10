package test;

use Test::More;
use Data::Dumper;

use Warteschlange::Queue;

my $queue = Warteschlange::Queue->new("/home/tobi/dev/warteschlange/t/workers");

$queue->enqueue('Testjobs::Boring');
ok(scalar @{$queue->list_all()} == 1, 'after enqueuing one job the queue consists of one job');

$queue->run($queue->next_pending_job());

done_testing();
