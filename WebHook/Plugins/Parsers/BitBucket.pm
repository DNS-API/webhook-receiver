
=head1 NAME

WebHook::Plugin::Parsers::BitBucket - Detect webhook request from bitbucket.

=cut


=head1 DESCRIPTION

Our webhook-receiver, implemented in C<WebHook::Receiver> will receive submissions
from various code-hosting services.   These submissions need to be examined
to discover which repository they contain.

The intention is that for each incoming event we receive we'll determine
a source/URL from which the corresponding repository can be pulled.

Our flow goes something like this:

=over 8

=item Receive a webhook request.

=item Parse the request to discover the repository to which it is associated.

=item Checkout the appropriate repository.

=back

Parsing the incoming request, from the JSON body, is delegated to a series
of plugins, each of which knows about a particular code-host.

This module understands how to identify Bitbucket repositories, both public
and private.

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

package WebHook::Plugins::Parsers::BitBucket;

use LWP::UserAgent;
use URI;



=head2 new

Constructor.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}



=head2 identify

Parse the specified JSON-reference, and see if it relates to a BitBucket
repository.  If it does return the URL which can be cloned.

If not we return undef/empty so that a later plugin can have a stab
at the decoding process.

=cut

sub identify
{
    my ( $self, $ref ) = (@_);

    my $result = undef;
    return ($result) unless ($ref);

    my %hash = %$ref;


    #
    #  Is it a new-style bitbucket webhook?
    #
    if ( $hash{ 'repository' }{ 'links' }{ 'html' }{ 'href' } )
    {
        $result = $hash{ 'repository' }{ 'links' }{ 'html' }{ 'href' };

        warn "REPO is bitbucket via new-style webhook: $result\n";

        #
        # We assume the repository is public by default.
        #
        my $private = 0;

        #
        # As the payload doesn't contain a public/private flag
        # we have to work out somehow if it is public/private.
        #
        # The current approach involves making a HTTP-request
        # and seeing if we can get a 401/200 status-code in response.
        #
        # If we see "200 OK" we know the URL is publicly available,
        # and therefor not private.  The reverse is true if we don't.
        #
        my $ua = LWP::UserAgent->new;
        $ua->agent("curl/7.38.0");
        $ua->timeout(10);
        $ua->env_proxy;

        # Attempt to fetch the Repo-URL
        my $response = $ua->get($result);

        if ( $response->is_success )
        {

            # The repository is public.
        }
        else
        {
            warn "The repository is private.";
            $private = 1;
        }

        if ($private)
        {

            #
            # Extract just the PATH the URL.
            #
            # e.g. /abhidg/dns/
            #
            my $uri  = new URI($result);
            my $path = $uri->path();

            #
            # Now we know where it lives.
            #
            $result = 'git@bitbucket.org:' . $path;
        }

    }
    return $result;
}



=head2 name

Return the (package) name of this plugin.

=cut

sub name {return __PACKAGE__;}


1;
