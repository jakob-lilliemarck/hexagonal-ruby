# typed: strict
# frozen_string_literal: true

require 'json'
require_relative '../../lib/utils/http_router'
require_relative '../../lib/driving/employee_service'

# Employee resource module
module EmployeeHandlers
  extend T::Sig

  # Route handlers for the employee resource
  class Routes
    extend T::Sig

    sig { params(router: HTTP::Router, employee_service: Core::EmployeeDrivingPort).void }
    def initialize(router, employee_service)
      router.register('GET', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::Errors::BadRequest unless id

        employee = employee_service.read(id)
        serialize(employee)
      rescue Driven::Errors::RecordNotFound
        raise HTTP::Errors::NotFound
      end

      router.register('GET', '/employees') do |_request|
        employees = employee_service.read_collection
        serialize_collection(employees)
      rescue Driven::Errors::RecordNotFound
        raise HTTP::Errors::NotFound
      end

      router.register('POST', '/employees') do |request|
        params = T.let(NewEmployeeParams.from_hash(request.body), NewEmployeeParams)
        employee = employee_service.create(params.name, Date.iso8601(params.birth))
        serialize(employee)
      rescue StandardError
        raise HTTP::Errors::ErrorUnknown
      end

      router.register('PUT', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::Errors::BadRequest unless id

        params = T.let(UpdateEmployeeParams.from_hash(request.body), UpdateEmployeeParams)
        employee = employee_service.update_name(id, params.name)
        serialize(employee)
      rescue TypeError
        raise HTTP::Errors::BadRequest
      rescue StandardError
        raise HTTP::Errors::ErrorUnknown
      end

      router.register('DELETE', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::Errors::BadRequest unless id

        employee_service.delete(id)
        nil
      rescue TypeError
        raise HTTP::Errors::BadRequest
      rescue StandardError
        raise HTTP::Errors::ErrorUnknown
      end
    end

    sig { params(employee: Core::Employee).returns(String) }
    def serialize(employee)
      {
        id: employee.id,
        name: employee.name,
        birth: employee.birth
      }.to_json
    end

    sig { params(employees: T::Array[Core::Employee]).returns(String) }
    def serialize_collection(employees)
      e = employees.map do |employee|
        {
          id: employee.id,
          name: employee.name,
          birth: employee.birth
        }
      end
      e.to_json
    end
  end

  # Struct defining required fields for new employee creation
  class NewEmployeeParams < T::Struct
    const :name, String
    const :birth, String
  end

  # Struct defines updateable required fields for existing employees
  class UpdateEmployeeParams < T::Struct
    const :name, String
  end
end
