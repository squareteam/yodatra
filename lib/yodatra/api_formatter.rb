module Yodatra
  class ApiFormatter

    def initialize(app, &block)
      @app = app
      @block = block if block_given?
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      status, headers, response = @app.call(env)

      status, headers, response = @block.yield(status, headers, response) unless @block.nil?

      headers['Content-Length'] = response.first.length.to_s unless response.nil? || response.first.nil?

      [status, headers, response]
    end

  end
end