
=head1 NAME

WebHook::Plugin::Parsers::GitBucket - Detect webhook request from gitbucket

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

This module understands how to identify repositories hosted on private
installations of GitBucket, both public and private.

Examples of such installations include http://git.steve.org.uk/

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

package WebHook::Plugins::Parsers::GitBucket;



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

Parse the specified JSON-reference, and see if it relates to a Github
repository.  If it does return the URL which can be cloned.

If not we return undef/empty so that a later plugin can have a stab
at the decoding process.

=cut

sub identify
{
    my ( $self, $ref ) = (@_);

    my $result = undef;
    return $result unless ($ref);

    my %hash = %$ref;


    if ( $hash{ 'repository' }{ 'clone_url' } )
    {
        $result = $hash{ 'repository' }{ 'clone_url' };

        warn "Repository is from gitbucket: $result\n";

        #
        #  Handle private repositories.
        #
        if ( $hash{ 'repository' }{ 'private' } &&
             ( $hash{ 'repository' }{ 'private' } ) )
        {
            warn "The repository is private\n";
        }
    }

    return $result;
}



=head2 name

Return the (package) name of this plugin.

=cut

sub name {return __PACKAGE__;}


1;
