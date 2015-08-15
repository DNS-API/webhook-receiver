
=head1 NAME

WebHook::Plugin::Queue::Redis - Enqueue new jobs to Redis.

=cut


=head1 DESCRIPTION

Our webhook-receiver, implemented in C<WebHook::Reciever> will receive submissions
from various code-hosting services.   Assuming each incoming request can
be successfully parsed and decoded then the net result will be a job.

The job will then be stored in a queue for later-processing, and this
enqueing is decoupled from the main core, by being implemented in a
queue-plugin.

This class implements an interface to the L<Redis> queue.

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut

use strict;
use warnings;

package WebHook::Plugins::Queue::Redis;

require Redis;




=head2 new

Constructor.

Here we connect to the Redis instance which is listening upon localhost.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );

    $self->{ 'redis' } = new Redis;

    return $self;
}



=head2 enqueue

This method is called by the server-core to queue the JSON-object to
a queue.  Here we append it to the Redis store, and return "1" to
allow the server to know that the job has been accepted.

=cut

sub enqueue
{
    my ( $self, $obj ) = (@_);

    #
    #  Store the JSON-object in the queue.
    #
    $self->{ 'redis' }->rpush( "HOOK:JOBS", $obj );

    #
    #  Report success
    #
    print "Enqueued to redis: $obj\n";
    return 1;
}

1;