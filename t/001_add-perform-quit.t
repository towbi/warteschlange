package test;

use Test::More;
use Data::Dumper;
use File::Basename;
use Module::Find qw(usesub);

use lib dirname($0);

require_ok('Warteschlange::Queue');

my $queue = Warteschlange::Queue->new();

foreach my $m (usesub 'Foo') {
    print "modu: $m\n";
}

$queue->can_do('Foo::Bar');

done_testing();

