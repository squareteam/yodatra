begin
  require 'redis'

  module Yodatra
    class Throttle
      def initialize(app, opts)
        @app = app
        @redis = Redis.new opts[:redis_conf]
        @rpm = opts[:rpm] || 100
      end

      def call(env)
        req = Rack::Request.new(env)
        key = "throttle:#{req.ip}"
        @redis.incr(key) == 1 && @redis.expire(key, 60)
        if @redis.get(key).to_i > @rpm
          Rack::Response.new('Too many API calls', 403)
        else
          @app.call(env)
        end
      end
    end
  end
rescue LoadError
  raise "Error: in order to use Yodatra's throttling middleware you will need Redis. Add 'redis' to your Gemfile or simply gem install 'redis'"
end