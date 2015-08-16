#!/usr/bin/perl -I.

use strict;
use warnings;

use JSON;
use Test::More qw! no_plan !;

#
# Load our module.
#
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
#  Now instantiate the helper
#
my $o = WebHook::Plugins::Parsers::GitHub->new();
ok( $o, "Created object" );
isa_ok( $o,
        "WebHook::Plugins::Parsers::GitHub",
        "The object has the right name." );
is( $o->name, "WebHook::Plugins::Parsers::GitHub", "Created the right object" );

#
#  Parse our JSON
#
my $json = from_json($txt);
ok( $json, "We did parse the JSON" );
is( ref $json, "HASH", "The JSON is a hash" );

#
#  Parse an empty string.
#
my $meh;
is( $o->identify($meh), undef, "Empty string was empty" );
is( $o->identify($json),
    'git@github.com:skx/private-dns.git',
    "Got the correct repository-source" );


__DATA__
{"ref":"refs/heads/master","before":"0000000000000000000000000000000000000000","after":"49213d7403a26a28b06ef1240f023338cd294a48","created":true,"deleted":false,"forced":true,"base_ref":null,"compare":"https://github.com/skx/private-dns/commit/49213d7403a2","commits":[{"id":"49213d7403a26a28b06ef1240f023338cd294a48","distinct":true,"message":"initial commit","timestamp":"2014-11-12T11:15:12Z","url":"https://github.com/skx/private-dns/commit/49213d7403a26a28b06ef1240f023338cd294a48","author":{"name":"Steve Kemp","email":"steve@steve.org.uk","username":"skx"},"committer":{"name":"Steve Kemp","email":"steve@steve.org.uk","username":"skx"},"added":["README.md"],"removed":[],"modified":[]}],"head_commit":{"id":"49213d7403a26a28b06ef1240f023338cd294a48","distinct":true,"message":"initial commit","timestamp":"2014-11-12T11:15:12Z","url":"https://github.com/skx/private-dns/commit/49213d7403a26a28b06ef1240f023338cd294a48","author":{"name":"Steve Kemp","email":"steve@steve.org.uk","username":"skx"},"committer":{"name":"Steve Kemp","email":"steve@steve.org.uk","username":"skx"},"added":["README.md"],"removed":[],"modified":[]},"repository":{"id":26532341,"name":"private-dns","full_name":"skx/private-dns","owner":{"name":"skx","email":"steve@steve.org.uk"},"private":true,"html_url":"https://github.com/skx/private-dns","description":"Testing.","fork":false,"url":"https://github.com/skx/private-dns","forks_url":"https://api.github.com/repos/skx/private-dns/forks","keys_url":"https://api.github.com/repos/skx/private-dns/keys{/key_id}","collaborators_url":"https://api.github.com/repos/skx/private-dns/collaborators{/collaborator}","teams_url":"https://api.github.com/repos/skx/private-dns/teams","hooks_url":"https://api.github.com/repos/skx/private-dns/hooks","issue_events_url":"https://api.github.com/repos/skx/private-dns/issues/events{/number}","events_url":"https://api.github.com/repos/skx/private-dns/events","assignees_url":"https://api.github.com/repos/skx/private-dns/assignees{/user}","branches_url":"https://api.github.com/repos/skx/private-dns/branches{/branch}","tags_url":"https://api.github.com/repos/skx/private-dns/tags","blobs_url":"https://api.github.com/repos/skx/private-dns/git/blobs{/sha}","git_tags_url":"https://api.github.com/repos/skx/private-dns/git/tags{/sha}","git_refs_url":"https://api.github.com/repos/skx/private-dns/git/refs{/sha}","trees_url":"https://api.github.com/repos/skx/private-dns/git/trees{/sha}","statuses_url":"https://api.github.com/repos/skx/private-dns/statuses/{sha}","languages_url":"https://api.github.com/repos/skx/private-dns/languages","stargazers_url":"https://api.github.com/repos/skx/private-dns/stargazers","contributors_url":"https://api.github.com/repos/skx/private-dns/contributors","subscribers_url":"https://api.github.com/repos/skx/private-dns/subscribers","subscription_url":"https://api.github.com/repos/skx/private-dns/subscription","commits_url":"https://api.github.com/repos/skx/private-dns/commits{/sha}","git_commits_url":"https://api.github.com/repos/skx/private-dns/git/commits{/sha}","comments_url":"https://api.github.com/repos/skx/private-dns/comments{/number}","issue_comment_url":"https://api.github.com/repos/skx/private-dns/issues/comments/{number}","contents_url":"https://api.github.com/repos/skx/private-dns/contents/{+path}","compare_url":"https://api.github.com/repos/skx/private-dns/compare/{base}...{head}","merges_url":"https://api.github.com/repos/skx/private-dns/merges","archive_url":"https://api.github.com/repos/skx/private-dns/{archive_format}{/ref}","downloads_url":"https://api.github.com/repos/skx/private-dns/downloads","issues_url":"https://api.github.com/repos/skx/private-dns/issues{/number}","pulls_url":"https://api.github.com/repos/skx/private-dns/pulls{/number}","milestones_url":"https://api.github.com/repos/skx/private-dns/milestones{/number}","notifications_url":"https://api.github.com/repos/skx/private-dns/notifications{?since,all,participating}","labels_url":"https://api.github.com/repos/skx/private-dns/labels{/name}","releases_url":"https://api.github.com/repos/skx/private-dns/releases{/id}","created_at":1415790838,"updated_at":"2014-11-12T11:13:58Z","pushed_at":1415790917,"git_url":"git://github.com/skx/private-dns.git","ssh_url":"git@github.com:skx/private-dns.git","clone_url":"https://github.com/skx/private-dns.git","svn_url":"https://github.com/skx/private-dns","homepage":null,"size":0,"stargazers_count":0,"watchers_count":0,"language":null,"has_issues":true,"has_downloads":true,"has_wiki":true,"has_pages":false,"forks_count":0,"mirror_url":null,"open_issues_count":0,"forks":0,"open_issues":0,"watchers":0,"default_branch":"master","stargazers":0,"master_branch":"master"},"pusher":{"name":"skx","email":"steve@steve.org.uk"},"sender":{"login":"skx","id":735291,"avatar_url":"https://avatars.githubusercontent.com/u/735291?v=3","gravatar_id":"","url":"https://api.github.com/users/skx","html_url":"https://github.com/skx","followers_url":"https://api.github.com/users/skx/followers","following_url":"https://api.github.com/users/skx/following{/other_user}","gists_url":"https://api.github.com/users/skx/gists{/gist_id}","starred_url":"https://api.github.com/users/skx/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/skx/subscriptions","organizations_url":"https://api.github.com/users/skx/orgs","repos_url":"https://api.github.com/users/skx/repos","events_url":"https://api.github.com/users/skx/events{/privacy}","received_events_url":"https://api.github.com/users/skx/received_events","type":"User","site_admin":false}}
