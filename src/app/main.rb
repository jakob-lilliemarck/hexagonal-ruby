# typed: strict
# frozen_string_literal: true

require 'json'
require 'sorbet-runtime'
require_relative 'handlers/employee_handlers'
require_relative '../lib/driven/employee_repository'

# API application
class App
  extend T::Sig

  sig { void }
  def initialize
    employee_repository = Driven::EmployeeRepository.new
    employee_service = Driving::EmployeeService.new(employee_repository)

    @router = T.let(HTTP::Router.new, HTTP::Router)
    @employee_repository = T.let(employee_repository, Driven::EmployeeRepository)
    @employee_service = T.let(employee_service, Driving::EmployeeService)

    EmployeeHandlers::Routes.new(@router, @employee_service)
  end

  sig do
    params(
      env: T::Hash[String, T.untyped]
    )
      .returns([Integer, T::Hash[String, String], T::Array[String]])
  end
  def call(env)
    method = env['REQUEST_METHOD']
    path = env['REQUEST_PATH']
    begin
      body_request = env['rack.input'].read
      body_json = T.let(body_request.empty? ? nil : JSON.parse(body_request), T.nilable(T::Hash[String, T.untyped]))
      @router.call(method, path, body_json)
    rescue StandardError
      [400, { 'Content-Type' => 'text/plain' }, ['Bad request']]
    end
  end
end
