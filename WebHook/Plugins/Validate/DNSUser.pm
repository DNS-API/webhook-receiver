
=head1 NAME

WebHook::Plugin::Validate::DNSUser - Ensure we have a dns-api.com account

=cut


=head1 DESCRIPTION

Our webhook-receiver, implemented in C<WebHook::Receiver> will call a series
of plugins to validate that submissions are associated with valid users.

Validation occurs by calling the C<validate> method of all plugins
which implement it.  If this method returns a value then it is assumed
to be a failure-explanation.

This plugin checks that the given username exists as a user on our
site.

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

package WebHook::Plugins::Validate::DNSUser;



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



=head2 new

Validation method.

Here we try to lookup the given username in our user-database.  If that
fails then we return a string to explain the user isn't present/valid.

=cut

sub validate
{
    my ( $self, $username ) = (@_);

    #
    # See if we can load our helper.
    #
    my $str = "use DNSAPI::User;";

    ## no critic (Eval)
    eval($str);
    ## use critic


    #
    #  If there were no errors validate the user via the helper.
    #
    if ( ! $@ )
    {
        my $helper = DNSAPI::User->new();

        #
        # Abort if the user doesn't exist.
        #
        return ("Submission for a user who doesn't exist.")
          unless $helper->exists($username);
    }

    return undef;
}

1;
