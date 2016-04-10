package test;

use Test::More;

use Warteschlange::Queue;

my $worker_dir = '/home/tobi/dev/warteschlange/t/workers';
my $queue = Warteschlange::Queue->new($worker_dir);
isa_ok($queue, Warteschlange::Queue);

ok($queue->can_do('Testjobs::Boring'), 'custom job class can be loaded');

done_testing();
