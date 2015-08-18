#!/usr/bin/perl -I.

use strict;
use warnings;

use JSON;
use Test::More qw! no_plan !;

#
# Load our module.
#
BEGIN {use_ok('WebHook::Plugins::Parsers::GitBucket');}
BEGIN {require_ok('WebHook::Plugins::Parsers::GitBucket');}
BEGIN {use_ok('WebHook::Plugins::Parsers::GitHub');}
BEGIN {require_ok('WebHook::Plugins::Parsers::GitHub');}


#
#  Load the payload from our body.
#
my $txt = "";
while ( my $line = <DATA> )
{
    $txt .= $line;
}


ok( length($txt), "We found a payload to test" );


#
#  Now instantiate the helper, which we expect to use successfully.
#
my $ok = WebHook::Plugins::Parsers::GitBucket->new();
ok( $ok, "Created object" );
isa_ok( $ok,
        "WebHook::Plugins::Parsers::GitBucket",
        "The object has the right name." );
is( $ok->name,
    "WebHook::Plugins::Parsers::GitBucket",
    "Created the right object" );


#
#  The GitHub plugin will not parse our payload, it is supposed
# to fail.
#
my $fail = WebHook::Plugins::Parsers::GitHub->new();
ok( $fail, "Created object" );
isa_ok( $fail,
        "WebHook::Plugins::Parsers::GitHub",
        "The object has the right name." );
is( $fail->name,
    "WebHook::Plugins::Parsers::GitHub",
    "Created the right object" );


#
#  Parse our JSON
#
my $json = from_json($txt);
ok( $json, "We did parse the JSON" );
is( ref $json, "HASH", "The JSON is a hash" );

#
#  Parse an empty string, then the real thing.
#
my $meh;
is( $ok->identify($meh), undef, "Empty string was empty" );
is( $ok->identify($json),
    'http://git.steve.org.uk/git/websites/dns-api.com.git',
    "Found the correct repository-source." );


#
#  Parse an empty string, then the real thing, which we
# expect to fail because it is the wrong-plugin
#
is( $fail->identify($meh),  undef, "Empty string was empty" );
is( $fail->identify($json), '',    "Failed to parse with the wrong-plugin" );


__DATA__
{"pusher":{"login":"websites","email":"websites@devnull","type":"Organization","site_admin":false,"created_at":"2014-08-24T19:12:48Z","url":"http://git.steve.org.uk/api/v3/users/websites","html_url":"http://git.steve.org.uk/websites"},"ref":"refs/heads/master","commits":[{"id":"37646d4b17f0a32d4552857713869fee30f9bbca","message":"Ensureusernamesaren'ttoolong:)\n","timestamp":"2015-08-17T08:22:03Z","added":["t/75-webhook-user-length.t"],"removed":[],"modified":[],"author":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:22:03Z"},"committer":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:22:03Z"},"url":"http://git.steve.org.uk/api/v3/websites/dns-api.com/commits/37646d4b17f0a32d4552857713869fee30f9bbca","html_url":"http://git.steve.org.uk/websites/dns-api.com/commit/37646d4b17f0a32d4552857713869fee30f9bbca"},{"id":"f74003878a37ea9d1e5b3ab78d258c808778316e","message":"Lenth-restricitonsonusernames.\n","timestamp":"2015-08-17T08:21:45Z","added":[],"removed":[],"modified":["hook/WebHook/Plugins/Validate/User.pm"],"author":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:21:45Z"},"committer":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:21:45Z"},"url":"http://git.steve.org.uk/api/v3/websites/dns-api.com/commits/f74003878a37ea9d1e5b3ab78d258c808778316e","html_url":"http://git.steve.org.uk/websites/dns-api.com/commit/f74003878a37ea9d1e5b3ab78d258c808778316e"},{"id":"bca876995e29d55ee2b16e04c059936d9c15cd9d","message":"Avoidusenrameslongerthan12characters\n","timestamp":"2015-08-17T08:16:30Z","added":[],"removed":[],"modified":["site/lib/WebApp/Application.pm"],"author":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:16:30Z"},"committer":{"name":"SteveKemp","email":"steve@steve.org.uk","date":"2015-08-17T08:16:30Z"},"url":"http://git.steve.org.uk/api/v3/websites/dns-api.com/commits/bca876995e29d55ee2b16e04c059936d9c15cd9d","html_url":"http://git.steve.org.uk/websites/dns-api.com/commit/bca876995e29d55ee2b16e04c059936d9c15cd9d"}],"repository":{"name":"dns-api.com","full_name":"websites/dns-api.com","description":"Thecodebehinddns-api.com","watchers":0,"forks":0,"private":true,"default_branch":"master","owner":{"login":"websites","email":"websites@devnull","type":"Organization","site_admin":false,"created_at":"2014-08-24T19:12:48Z","url":"http://git.steve.org.uk/api/v3/users/websites","html_url":"http://git.steve.org.uk/websites"},"forks_count":0,"watchers_coun":0,"url":"http://git.steve.org.uk/api/v3/repos/websites/dns-api.com","http_url":"http://git.steve.org.uk/git/websites/dns-api.com.git","clone_url":"http://git.steve.org.uk/git/websites/dns-api.com.git","html_url":"http://git.steve.org.uk/websites/dns-api.com"}}


