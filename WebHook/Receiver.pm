#!/usr/bin/perl -w -I/srv/current/common/ -I/srv/current/hook/

=head1 NAME

WebHook::Receiver - Process incoming webhook events.

=cut


=head1 DESCRIPTION

This class contains a C<Mojolicious::Lite>-derived application which listens for incoming
HTTP requests.  These requests should be webhook requests from various
code-hosting services (currently "github" and "bitbucket").

Each incoming request will be a HTTP-post, or a JSON-submission, and should
be examined to discover two things:

=over 8

=item The dns-api.com user to which the request relates.

=item The source-repository from which it was initiated.

=back

We can discover the username easily enough because the POST request should
be sent to C</$username>, but to discover the source repository requires
parsing the payload to discover where it came from - and the contents of
the payload will vary on a per-service basis.

To allow easy updates, and testing in isolation, the examination of the
payloads is carried out in a series of plugins.  Each plugin which implements
an C<identify> method will be called in turn - if the plugin returns
something from that method then further processing is stopped.

Once the C<identify> plugins have identified a source-repository then
further plugins are called, if present, to add the incoming submission
to a work-queue.

Currently we only support one queue-type, which is based upon L<Redis>,
and that is implemented in L<WebHook::Plugin::Queue::Redis>.

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut



use strict;
use warnings;


package WebHook::Receiver;


#
# Standard modules.
#
use HTML::Entities;
use JSON;
use Mojolicious::Lite;
use URI;
use UUID::Tiny;


#
#  Load our plugins - ensuring that we call their constructors.
#
use Module::Pluggable
  search_path => ['WebHook::Plugins'],
  instantiate => 'new';




#
#  The handler which is invoked when we see POST requests
# to a user-end-point.
#
post '/:user' => sub {
    my $c    = shift;
    my $user = $c->stash('user');

    #
    #  Ensure we got a user.
    #
    if ( !length($user) )
    {
        return $c->render( text => 'Missing User', status => 500 );
    }


    #
    #  Now validate our user via the `validate` method of any
    # plugins we found.
    #
    foreach my $plugin ( plugins() )
    {

        # Skip non-validating plugins.
        next unless ( UNIVERSAL::can( $plugin, 'validate' ) );

        # Call the plugin.
        my $bogus = $plugin->validate($user)

        if ($bogus)
        {
            return (
                     $c->render( text   => "User validation failed: $bogus.",
                                 status => 500
                               ) );
        }
    }


    #
    #  Get the body from the submission.
    #
    my $body = $c->req->body || "";
    my $len = length($body);

    ##
    ## Logging.
    ##
    my $header = "Submission for user $user from " . $c->tx->remote_address;
    print "\n$header\n";
    print "=" x ( length($header) ) . "\n";
    print scalar localtime . "\n";
    print "Body $len bytes:\n";
    print "$body\n";

    #
    #  If the body is too small / too big abort
    #
    if ( $len < 1 )
    {
        return $c->render( text => 'Missing/Empty body.', status => 500 );
    }
    if ( $len > ( 256 * 1024 ) )
    {
        return $c->render( text => 'Body too large', status => 500 );
    }


    #
    #  If we're recieving something that has a payload key then
    # we replace the body with that.
    #
    #  NOTE:  This is used by the bitbucket "service" POSTs, not by
    # github, or the new-style bitbucket webhook support.
    #
    if ( $c->param("payload") )
    {
        $body = $c->param("payload");
        warn "Replaced body with payload argument.";
    }


    #
    # If the body is some kind of payload-object then expand that too.
    #
    if ( $body =~ /^payload=(.*)/ )
    {
        $body = $1;
        $body = decode_entities($body);
        $body =~ s/\+//g;
    }


    #
    #  Decode the JSON.
    #
    my $obj = undef;
    eval {$obj = from_json($body);};
    if ($@)
    {
        return $c->render( text => 'Failure to evaluate JSON', status => 500 );
    }

    #
    # Ensure we decoded it properly.
    #
    if ( !$obj )
    {
        return $c->render( text => 'Invalid JSON', status => 500 );
    }

    #
    #  Ensure that the JSON decoded to a hash - heuristically all the
    #  sites and services I examined will send a hash.
    #
    if ( ref $obj ne "HASH" )
    {
        return (
             $c->render( text => "JSON didn't decode to a hash", status => 500 )
        );
    }


    #
    #  Hashify the object.
    #
    my %hash = %$obj;

    #
    #  The object we'll add to the queue will have three fields:
    #
    #  1.  The owner of the job.
    #
    #  2.  A unique identifier.
    #
    #  3.  The URL which can be "git clone ..." from.
    #
    #  The first two we know now, the last one we'll determine via our
    # decoding-plugins.
    #
    my %queue;
    $queue{ 'uuid' }  = UUID::Tiny::create_uuid_as_string();
    $queue{ 'owner' } = $user;

    #
    #  Call each of our plugins in-turn until we get a result
    #
    foreach my $plugin ( plugins() )
    {

        # First plugin wins.
        next if ( $queue{ 'url' }  );

        # Skip plugins that don't implement our method.
        next unless ( UNIVERSAL::can( $plugin, 'identify' ) );

        # Call the plugin
        $queue{ 'url' } = $plugin->identify( \%hash );
    }

    #
    #  If we didn't identify a repo then we need to alert the caller
    #
    return ( $c->render( text => "Failed to identify source-repository" ) )
      unless ( $queue{'url'} );


    #
    #  Now encode the data to JSON, so that it can be added to our queue.
    #
    my $res = to_json( \%queue );

    #
    #  Call each enqueuing plugin - the first one that reports that it
    # has added it to the queue will win, and do it.
    #
    if ( !$ENV{ 'TESTING' } )
    {
        my $queued = 0;

        foreach my $plugin ( plugins() )
        {

            # We only enqueue once.
            next if ($queued);

            # Skip non-queue plugins
            next unless ( UNIVERSAL::can( $plugin, 'enqueue' ) );

            # Call the plugin.
            $queued = $plugin->enqueue($res);
        }
    }


    #
    #  Give the submitter something to consume.
    #
    return ( $c->render( text => "Submission accepted - $queue{'uuid'}" ) );
};




#
#  Redirect any other end-points to our main site.
#
any '/(*)' => sub {
    my $self = shift;
    my $site = $ENV{ "SITE" } || 'https://dns-api.com/';
    return ( $self->redirect_to($site) );
};


#
#  Redirect any other end-points to our main site.
#
any '/' => sub {
    my $self = shift;
    my $site = $ENV{ "SITE" } || 'https://dns-api.com/';
    return ( $self->redirect_to($site) );
};



1;
