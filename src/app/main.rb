# typed: strict
require 'json'
require 'sorbet-runtime'
require_relative '../lib/utils/http_router'
require_relative '../lib/driving/employee_service'

class App
  extend T::Sig
  
  sig { params(router: HTTP::Router).void }
  def initialize(router)
    @router = T.let(router, HTTP::Router)
  end
  
  sig {
    params(
      env: T::Hash[String, T.untyped])
    .returns([Integer, T::Hash[String, String], T::Array[String]])
  }
  def call(env)
    method = env['REQUEST_METHOD']
    path = env['REQUEST_PATH']
    begin
      body_request = env['rack.input'].read
      body_json = T.let(body_request.empty? ? nil : JSON.parse(body_request), T.nilable(T::Hash[String, T.untyped]))
      @router.call(method, path, body_json)
    rescue
      [400, {'Content-Type' => 'text/plain'}, ['Bad request']]
    end
  end
end
