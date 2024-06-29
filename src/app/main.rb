# typed: strict
require 'json'
require 'sorbet-runtime'
require_relative 'resources/employee'
class App
  extend T::Sig
  
  sig { void }
  def initialize()
    @router = T.let(HTTP::Router.new, HTTP::Router)
    
    EmployeeResource::Routes.new(@router)
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
