
=head1 NAME

WebHook::Plugin::Validate::User - Avoid bogus usernames.

=cut


=head1 DESCRIPTION

Our webhook-receiver, implemented in C<WebHook::Reciever> will call a series
of plugins to validate that submissions are associated with valid users.

Validation occurs by calling the C<validate> method of all plugins
which implement it.  If this method returns a value then it is assumed
to be a failure-explanation.

This plugin checks that the given username is well-formed.

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

package WebHook::Plugins::Validate::User;




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



=head2 validate

Validation method.

Here we test that the username is present, and doesn't contain surprising
characters.

=cut

sub validate
{
    my ( $self, $username ) = (@_);

    # No username?  That's bogus
    return "Missing username" unless ($username);

    # Ensure the username isn't too long.
    if ( length($username) > 12 )
    {
        return "The username is too long.";
    }

    # Ensure the username is well-formed
    if ( $username !~ /^([a-z0-9_-]+)$/i )
    {
        return "Invalid username";
    }

    #
    #  All is OK
    #
    return "";
}



=head2 name

Return the (package) name of this plugin.

=cut

sub name {return __PACKAGE__;}



1;

