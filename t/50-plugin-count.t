#!/usr/bin/perl -I/srv/current/hook/

use strict;
use warnings;

use Test::More qw! no_plan !;

#
# Load the plugin-interface
#
use Module::Pluggable
  search_path => ['WebHook::Plugins'],
  instantiate => 'new';


#
#  The kinds of plugins we expect
#
my %hash = ( identify => 3,
             enqueue  => 1,
             validate  => 2,
             name     => 6,
             new      => 6
           );


#
#  Load each plugin
#
foreach my $method ( keys %hash )
{
    my $count = 0;

    foreach my $plugin ( plugins() )
    {
        $count += 1 if ( UNIVERSAL::can( $plugin, $method ) );
    }

    is( $count,
        $hash{ $method },
        "We found the correct number of plugins implementing: $method" );
}
