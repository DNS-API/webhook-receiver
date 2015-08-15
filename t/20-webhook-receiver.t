#!/usr/bin/perl -I/srv/current/common/ -I/srv/current/hook/

BEGIN {$ENV{ 'TESTING' } = 1;}

use strict;
use warnings;

use JSON;
use Test::More qw! no_plan !;
use Test::Mojo;



my $location_is = sub {
    my ( $t, $value, $desc ) = @_;
    $desc ||= "Location: $value";
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return ( is( $t->tx->res->headers->location, $value, $desc ) );
};


#
# Load our module.
#
BEGIN {use_ok('WebHook::Receiver');}
require_ok('WebHook::Receiver');

#
# Create our helper.
#

my $t = Test::Mojo->new;

#
# Accessing the server root should result in a redirection to our
# real site
#
$t->get_ok("/")->status_is(302)->$location_is('https://dns-api.com/');
$t->get_ok("/missing")->status_is(302)->$location_is('https://dns-api.com/');
$t->get_ok("/missing/path/goes/here")->status_is(302)
  ->$location_is('https://dns-api.com/');

#
#  Posting to the root, or subdirectories, will also result in a redirection
#
$t->post_ok( '/' => form => { q => 'Perl' } )->status_is(302)
  ->$location_is('https://dns-api.com/');
$t->post_ok( '/boo/bar' => form => { q => 'Perl' } )->status_is(302)
  ->$location_is('https://dns-api.com/');



#
#  Now we're going to post some valid JSON to a legitimate end-point
#
$t->post_ok( '/bogus_user' => json => { blah => 12 } )->status_is(500)
  ->content_like(qr/submission for a user who doesn't exist./i);

#
#  Now try to post something that won't work.
#
$t->post_ok( '/root' => json => { foo => 'bob' } )->status_is(500)
  ->content_like(qr/^failure to evaluate JSON$/i);

#
#  One last try with an empty body
#
$t->post_ok( '/root' => {} )->status_is(500)
  ->content_like(qr/^missing\/empty body.$/i);

#
#  Now we post a JSON-array (i.e. somethign that is bad);
#
my @h;
push( @h, "Steve" );
push( @h, "Kemp" );

my $json = encode_json( \@h );
$t->post_ok( '/root' => {} => $json )->status_is(500)
  ->content_like(qr/JSON didn't decode to a hash/i);


#
#  Finally we POST a JSON-hash.
#
#  (i.e. something that should be good, but won't be because
# it is impossible to parse.)
#
my $h;
$h->{ 'steve' } = "kemp";
$json = encode_json($h);
$t->post_ok( '/root' => {} => $json )->status_is(200)
  ->content_like(qr/^Failed to identify source-repository/i);



