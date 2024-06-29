# typed: strict

require 'json'
require_relative '../../lib/utils/http_router'
require_relative '../../lib/driving/employee_service'

module EmployeeResource
  extend T::Sig

  class NewUserParams < T::Struct
    const :name, String
    const :birth, String
  end

  class UpdateUserParams < T::Struct
    const :name, String
  end

  class Routes
    extend T::Sig

    sig { params(router: HTTP::Router, employee_repository: Core::EmployeeDrivenPort).void }
    def initialize(router, employee_repository)
      router.register('GET', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::BadRequest unless id

        service = Driving::EmployeeService.new(employee_repository)
        employee = service.read(id)
        serialize(employee)
      rescue Driven::RecordNotFound
        raise HTTP::NotFound
      end

      router.register('GET', '/employees') do |_request|
        service = Driving::EmployeeService.new(employee_repository)
        employees = service.read_collection
        serialize_collection(employees)
      rescue Driven::RecordNotFound
        raise HTTP::NotFound
      end

      router.register('POST', '/employees') do |request|
        params = T.let(NewUserParams.from_hash(request.body), NewUserParams)
        employee_service = Driving::EmployeeService.new(employee_repository)
        employee = employee_service.create(params.name, Date.iso8601(params.birth))
        serialize(employee)
      rescue StandardError
        raise HTTP::ErrorUnknown
      end

      router.register('PUT', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::BadRequest unless id

        params = T.let(UpdateUserParams.from_hash(request.body), UpdateUserParams)
        employee_service = Driving::EmployeeService.new(employee_repository)
        employee = employee_service.update_name(id, params.name)
        serialize(employee)
      rescue TypeError
        raise HTTP::BadRequest
      rescue StandardError
        raise HTTP::ErrorUnknown
      end

      router.register('DELETE', '/employees/:id') do |request|
        id = request.params[:id]
        raise HTTP::BadRequest unless id

        employee_service = Driving::EmployeeService.new(employee_repository)
        employee_service.delete(id)
        nil
      rescue TypeError
        raise HTTP::BadRequest
      rescue StandardError
        raise HTTP::ErrorUnknown
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
end
