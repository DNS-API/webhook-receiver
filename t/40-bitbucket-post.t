#!/usr/bin/perl -I. -I..

use strict;
use warnings;

use JSON;
use Test::More qw! no_plan !;

#
# Load our module.
#
BEGIN {use_ok('WebHook::Plugins::Parsers::BitBucket;');}


#
#  Load the payload from our body.
#
my $txt = "";
while( my $line = <DATA> )
{
    $txt .= $line;
}


ok( length($txt), "We found a payload to test" );


#
#  Now instantiate the helper
#
my $o = WebHook::Plugins::Parsers::BitBucket->new();
ok( $o, "Created object");
isa_ok( $o, "WebHook::Plugins::Parsers::BitBucket" , "The object has the right name." );
is( $o->name, "WebHook::Plugins::Parsers::BitBucket", "Created the right object" );

#
#  Parse our JSON
#
my $json = from_json( $txt );
ok( $json, "We did parse the JSON" );
is( ref $json, "HASH", "The JSON is a hash" );

#
#  Parse an empty string.
#
my $meh;
is( $o->identify( $meh ), undef, "Empty string was empty" );
is( $o->identify( $json ), 'git@bitbucket.org:/example/dns', "Found the correct repository-source." );


__DATA__
{"repository": {"name": "dns", "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns"}, "html": {"href": "https://bitbucket.org/example/dns"}, "avatar": {"href": "https://bitbucket.org/example/dns/avatar/16/"}}, "owner": {"display_name": "forename surname", "username": "example", "type": "user", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/example"}, "html": {"href": "https://bitbucket.org/example/"}, "avatar": {"href": "https://bitbucket.org/account/example/avatar/32/"}}, "uuid": "{ffc95bee-b838-4e4d-a77b-28cfcec956fd}"}, "type": "repository", "full_name": "example/dns", "uuid": "{13716a3b-1e8f-4aa1-9cf7-75debb84bc3c}"}, "push": {"changes": [{"new": {"name": "master", "type": "branch", "target": {"hash": "ae0db26012e0c1302a49a474753ca279cc473208", "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commit/ae0db26012e0c1302a49a474753ca279cc473208"}, "html": {"href": "https://bitbucket.org/example/dns/commits/ae0db26012e0c1302a49a474753ca279cc473208"}}, "message": "update with correct ipv6 encoding\n", "date": "2015-08-11T12:15:10+00:00", "author": {"raw": "forename surname <example@example.net>"}, "type": "commit", "parents": [{"hash": "a2340b4b9465b142cffb8e59764893e82982a9dd", "type": "commit", "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commit/a2340b4b9465b142cffb8e59764893e82982a9dd"}, "html": {"href": "https://bitbucket.org/example/dns/commits/a2340b4b9465b142cffb8e59764893e82982a9dd"}}}]}, "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/refs/branches/master"}, "commits": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commits/master"}, "html": {"href": "https://bitbucket.org/example/dns/branch/master"}}}, "links": {"diff": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/diff/ae0db26012e0c1302a49a474753ca279cc473208..a2340b4b9465b142cffb8e59764893e82982a9dd"}, "commits": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commits?include=ae0db26012e0c1302a49a474753ca279cc473208&exclude=a2340b4b9465b142cffb8e59764893e82982a9dd"}, "html": {"href": "https://bitbucket.org/example/dns/branches/compare/ae0db26012e0c1302a49a474753ca279cc473208..a2340b4b9465b142cffb8e59764893e82982a9dd"}}, "truncated": false, "forced": false, "old": {"name": "master", "type": "branch", "target": {"hash": "a2340b4b9465b142cffb8e59764893e82982a9dd", "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commit/a2340b4b9465b142cffb8e59764893e82982a9dd"}, "html": {"href": "https://bitbucket.org/example/dns/commits/a2340b4b9465b142cffb8e59764893e82982a9dd"}}, "message": "add ttl to txt\n", "date": "2015-08-11T12:03:00+00:00", "author": {"raw": "forename surname <example@example.net>"}, "type": "commit", "parents": [{"hash": "a1239be9256b239109647edfeda20eb57498fcd2", "type": "commit", "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commit/a1239be9256b239109647edfeda20eb57498fcd2"}, "html": {"href": "https://bitbucket.org/example/dns/commits/a1239be9256b239109647edfeda20eb57498fcd2"}}}]}, "links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/refs/branches/master"}, "commits": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commits/master"}, "html": {"href": "https://bitbucket.org/example/dns/branch/master"}}}, "closed": false, "created": false, "commits": [{"links": {"self": {"href": "https://api.bitbucket.org/2.0/repositories/example/dns/commit/ae0db26012e0c1302a49a474753ca279cc473208"}, "html": {"href": "https://bitbucket.org/example/dns/commits/ae0db26012e0c1302a49a474753ca279cc473208"}}, "author": {"raw": "forename surname <example@example.net>"}, "message": "update with correct ipv6 encoding\n", "type": "commit", "hash": "ae0db26012e0c1302a49a474753ca279cc473208"}]}]}, "actor": {"display_name": "forename surname", "username": "example", "type": "user", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/example"}, "html": {"href": "https://bitbucket.org/example/"}, "avatar": {"href": "https://bitbucket.org/account/example/avatar/32/"}}, "uuid": "{ffc95bee-b838-4e4d-a77b-28cfcec956fd}"}}
