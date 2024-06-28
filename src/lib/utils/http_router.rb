# typed: strict
require 'sorbet-runtime'

module HTTP
  extend T::Sig

  Response = T.type_alias { [Integer, T::Hash[String, String], T::Array[String]] }

  Handler = T.type_alias { T.proc.params(request: HTTP::Request).returns(T.nilable(String)) }

  class ErrorUnknown < StandardError
    extend T::Sig
  
    sig { void }
    def initialize
      super("Unknown error")
    end
  end

  class BadRequest < StandardError
    extend T::Sig
  
    sig { void }
    def initialize
      super("Bad request")
    end
  end

  class NotFound < StandardError
      extend T::Sig
    
      sig { void }
      def initialize
        super("Not found")
      end
  end

  class Request < T::Struct
    const :params, T::Hash[Symbol, String]
    const :body, T.nilable(T::Hash[String, T.untyped])
  end

  class RouteRecord < T::Struct
    const :path, String
    const :handler, Handler
  end

  class Router < T::Struct
    extend T::Sig

    prop :handlers, T::Hash[String, Handler], default: {}

    sig { params( method: String, path: String, handler: Handler).void }
    def register(method, path, &handler)
      route = fmt(method, path)
      @handlers[route] = handler
    end

    sig { params(method: String, path: String, body: T.nilable(T::Hash[String, T.untyped])).returns(Response) }
    def call(method, path, body)
      begin
        record = match_route(method, path)
        params = parse_params(record.path, path)
        request = Request::new(params: params, body: body)
        resource = record.handler.call(request)
        [200, {'Content-Type' => 'application/json'}, [resource || '']]
      rescue NotFound
        [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
      rescue BadRequest
        [400, {'Content-Type' => 'text/plain'}, ['Bad request']]
      end
    end

    private

    # Matches a given path against registered route patterns and returns the matched pattern.
    sig { params(method: String, path: String).returns(RouteRecord) }
    def match_route(method, path)
      # Extracts the patterns from @handlers keys, removing the HTTP method part
      patterns = @handlers.keys

      # Iterates through each pattern to find a match for the given path
      patterns.each do |pattern|
        # Splits the pattern into method and path parts
        pattern_method, pattern_path = pattern.split(' ', 2)

        raise NotFound.new if !pattern_method || !pattern_path

        # Skip if the HTTP method does not match
        next if pattern_method != method

        # Replaces the parameter keys in the pattern with the regex pattern for capturing values
        regex_pattern = pattern_path.gsub(/:[^\/]+/, '[^\/]+')

        # If the path does not match the regex pattern, skip to the next pattern
        next unless fmt(method, path).match(/^#{method} #{regex_pattern}$/)

        # Retrieves the handler for the route from the @handlers hash
        handler = @handlers[pattern]

        # If a handler is found, return a new RouteRecord with the matched pattern and handler
        return RouteRecord.new(path: pattern_path, handler: handler) if handler
      end

      # If no pattern matches the path, return nil
      raise NotFound.new
    end

    # Matches a given path against registered route patterns and returns the matched pattern.  
    sig { params(pattern: String, actual: String).returns(T::Hash[Symbol, String]) }
    def parse_params(pattern, actual)
      # Extracts the parameter keys from the pattern (e.g., :id, :name)
      keys = pattern.scan(/:([a-zA-Z_]+)/).flatten

      # Replaces the parameter keys in the pattern with the regex pattern for capturing values
      capture_pattern = pattern.gsub(pattern_param_key, pattern_param_value.to_s)

      # Matches the actual path against the modified regex pattern
      matches = actual.match(/^#{capture_pattern}$/)

      # Initializes an empty hash to store the extracted parameters
      result = {}

      # Iterates over the extracted keys and their indices
      keys.each_with_index do |name, index|
        if matches
          # Converts the key to a symbol and assigns the corresponding matched value to the result hash
          result[name.to_sym] = matches[index + 1]
        end
      end

      # Returns the result hash containing the parameter names and their values
      result
    end

    sig { returns(Regexp) }
    def pattern_param_key
      # The regex pattern /:[a-zA-Z_]+/ matches : followed by one or more letters or underscores
      /:[a-zA-Z_]+/
    end

    sig { returns(Regexp) }
    def pattern_param_value
      # '([^/]+)' is a regex pattern that matches any sequence of characters except for /
      /([^\/]+)/
    end

    # Formats an HTTP method and path into a single string.
    sig { params(method: String, path: String).returns(String) }
    def fmt(method, path)
      # Combine the method and path into a single string, separated by a space
      "#{method} #{path}"
    end
  end
end