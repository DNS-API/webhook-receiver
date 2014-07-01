##
## Trivial ClassFactory pattern to allow multiple queue-backends
##



#
#  Attempt to load the libraries for our two backend modules.
#
#  This is setup because the user might only choose to use one backend
# and not care if the other doesn't even load.
#
%w( beanstalk-client redis ).each do |library|
  begin
    require library
    puts "Loaded: #{library}"
  rescue LoadError
    puts "Failed to load the library: #{library}"
  end
end





#
# This is a trivial abstraction layer between the Sinatra application
# and the queue we use.
#
class Queue

  #
  # Class-Factory
  #
  def self.create type
    case type
    when "redis"
      RedisQueue.new
    when "beanstalk"
      BeanstalkQueue.new
    else
      raise "Bad backend type: #{type}"
    end
  end


  #
  # Add the given JSON-encoded object to the queue.
  #
  def add( object )
    raise "Subclasses must implement this method!"
  end

end





#
# The redis-based queue.
#
class RedisQueue < Queue


  #
  # Constructor.
  #
  def initialize
    rehost = ENV["REDIS"] || "127.0.0.1"
    @redis = Redis.new( :host => rehost )
  end


  #
  # Add the JSON-encoded object to the queue.
  #
  def add( json )
    @redis.rpush( "HOOK:JOBS", json )
  end

end









#
# The beanstalkd-based queue.
#
class BeanstalkQueue < Queue


  #
  # Constructor.
  #
  def initialize
    @beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
  end


  #
  # Add the JSON-encoded object to the queue.
  #
  def add( json )
    @beanstalk.put( json )
  end

end





