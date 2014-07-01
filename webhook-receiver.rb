#!/usr/bin/ruby1.9.1
#
# This service receive HTTP-POST requests as "webhooks" from supported
# git-hosting services.
#
# The goal of this service is to accept those requests and enqueue
# the decoded content in a local Redis-instance.
#
# Although we aim to support arbitrary Git-hosting services we currently
# handle only BitBucket & GitHub.
#
# The important thing is to parse out the remote source, such that a later
# process can run:
#
#     $ git clone --quiet $src
#
# Here we assume that clients will send their webhook to:
#
#     http://example.com:9898/$username
#
# It is an error to POST a request to the bare root of the server,
# and if an unrecognized end-point is called we'll just redirect
# to our main site.
#
# Queuing
# -------
#
# When a post comes in we'll parse two things from it:
#
#  * The public repository URL.
#  * The ID of the repository - which is assumed to never change.
#
# These two items, along with some other data, are added to a Redis
# queue for later processing.  However we should also allow different
# queues.
#
# Steve
# --
#


require 'getoptlong'
require 'json'
require 'pp'
require 'redis'
require 'sinatra/base'
require 'time'


#
#  Our handler is Sinatra-based.
#
class WebHookReceiver < Sinatra::Base

  #
  #  The default port we listen upon.
  #
  set :port, 9898

  #
  #  The environment
  #
  set :environment, "production"


  #
  #  Constructor - Just remember our debug-setting.
  #
  def initialize
    super
    @debug = ( ! ENV['DEBUG'].nil? ) ? true : false
  end


  #
  # Handle a WebHook from a remote Git service.
  #
  post '/:name/?' do

    #
    #  Get *our* account name, from the hook.
    #
    #  If there is no name then this is a bogus/malicious submission.
    #
    user=params[:name]

    if ( user.nil? || user.empty? )
      return 500, "Missing username to associate this hook with."
    end


    #
    #  Reset the body so that we can slurp it up
    #
    request.body.rewind
    body = request.body.read


    #
    #  If we're debugging then show the body we received.
    #
    if ( @debug )
      puts " "
      log = "Submission for user #{user} from #{request.ip}"
      puts log
      puts "=" * ( log.size )
      puts body
      puts "Body size is: #{body.size}"
    end


    #
    #  If the body-size is "too big" then this is an error
    #
    if ( body.size >= 1024 * 256 )
       return 500, "Body is excessively large - rejecting as possibly malicious"
    end


    #
    #  Now we need to parse the body.
    #
    #  Currently we support two remote sources:
    #
    #   * BitBucket.com
    #
    #   * GitHub.com
    #


    #
    #  Is the body a BitBucket body?
    #
    if ( body =~ /^payload=(.*)/ )
      body = $1.dup
      body = URI.unescape( body )
      body.gsub!(/\+/, '' )
    end

    #
    #  The decoded-body, from the JSON submission.
    #
    obj = nil

    #
    #  Parse the JSON
    #
    begin
      obj = JSON.parse( body )
    rescue JSON::ParserError

      if ( @debug )
        puts "The body failed to parse as JSON"
      end

      return 500, "Parse Error - Malformed JSON"
    end

    #
    #  Ensure the parsing was successful.
    #
    if ( obj.nil? )

      if ( @debug )
        puts "JSON decoded to an empty object.  Weirdness."
      end

      return 500, "The body was not parsed as JSON"
    end


    #
    #  Ensure the parsing gave us something sensible
    #
    if ( ! obj.kind_of? Hash )
      if ( @debug )
        puts "The decoded object was not a hash - was #{obj.kind_of?}"
      end

      return 500, "The body was not a Hash, as expected"
    end


    #
    #  We don't know what kind of hook invoked us.
    #
    type = "unknown";

    #
    #  This is GitHub
    #
    if ( !obj['repository']['id'].nil? )
      id=obj['repository']['id']
      url=obj['repository']['url']
      type = "github"
    end

    #
    #  This is BitBucket
    #
    if ( !obj["repository"]["absolute_url"].nil? )
      url="https://bitbucket.org#{obj["repository"]["absolute_url"]}"
      id=obj["repository"]["absolute_url"]
      id.gsub!(/\//, '_' )
      type = "bitbucket"
    end


    #
    #  Build up a hash to store in queue of submissions to process.
    #
    obj = {}
    obj[:id]    = id    # From the POST
    obj[:url]   = url   # From the POST.
    obj[:type]  = type
    obj[:owner] = user
    obj[:uuid]  = SecureRandom.uuid


    #
    #  The JSON-encoded result we'll add to the queue.
    #
    res = obj.to_json


    #
    #  Show it.
    #
    if ( @debug )
      puts "Adding to queue: #{res}"
    end

    #
    #  Enqueue it.
    #
    #  TODO: Support multiple queues.
    #
    Redis.new().rpush( "HOOK:JOBS", res )

    #
    #  Return value - just a string.
    #
    #  * GitHub will make this available on the hooks page,
    #  * BitBucket seems to silently ignore it.
    #
    return( obj[:uuid] )

  end


  #
  #  Redirection handler
  #
  # If the user hits an end-point we don't recognize then
  # redirect to our live site.
  #
  not_found do
    site = ENV["SITE"] || 'https://dns-api.com/'
    redirect site, 'This is for recieving hooks by POST'
  end

end






#
# Launch the server
#
if __FILE__ == $0

  opts = GetoptLong.new(
                        [ '--debug',   '-d', GetoptLong::NO_ARGUMENT ],
                        [ '--port',    '-p', GetoptLong::REQUIRED_ARGUMENT ],
                        [ '--verbose', '-v', GetoptLong::NO_ARGUMENT ]
                        )

  begin
    opts.each do |opt,arg|
      case opt
      when '--debug'
        ENV["DEBUG"]= "1"
      when '--port'
        if ( arg =~ /^([0-9]+)$/ )
            WebHookReceiver.port = arg
        else
            puts "Port must be numeric"
            exit(1)
        end
      when '--verbose'
        ENV["DEBUG"]= "1"
      end
    end
  rescue
    exit(1)
  end


  #
  # Ensure our output appears immediately - needed
  # because otherwise we'll have some lag.
  #
  STDOUT.sync = true

  #
  # Show a banner on startup
  #
  puts( "Application starting at #{Time.now} on http://127.0.0.1:#{WebHookReceiver.port}" )

  #
  #  Launch - This will not return unless there is an error.
  #
  WebHookReceiver.run!

end

