# typed: strict
require 'json'
require_relative '../lib/utils/http_router'
require_relative '../lib/driving/employee_service'
require_relative '../lib/driven/employee_repository'

$router = HTTP::Router.new

extend T::Sig

sig { returns([Integer, T::Hash[String, String], T::Array[String]]) }
def not_found
    [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
end

$router.register('GET', '/employees/:id') do |request|
    begin
        id = request.params[:id]

        raise HTTP::BadRequest if !id
        
        service = Driving::EmployeeService.new

        service.read(id)
    rescue Driven::RecordNotFound
        raise HTTP::NotFound
    end
end

$router.register('GET', '/employees') do |request|
    begin        
        service = Driving::EmployeeService.new

        service.read_collection
    rescue Driven::RecordNotFound
        raise HTTP::NotFound
    end
end

class NewUserParams < T::Struct
    const :name, String
    const :birth, String
end

$router.register('POST', '/employees') do |request|
    begin
        params = T.let(NewUserParams.from_hash(request.body), NewUserParams)        

        employee_service = Driving::EmployeeService.new
        
        employee_service.create(params.name, Date.iso8601(params.birth))
    rescue
        raise HTTP::ErrorUnknown
    end
end

class UpdateUserParams < T::Struct
    const :name, String
end

$router.register('PUT', '/employees/:id') do |request|
    begin
        id = request.params[:id]

        raise HTTP::BadRequest if !id

        params = T.let(UpdateUserParams.from_hash(request.body), UpdateUserParams)       
        
        employee_service = Driving::EmployeeService.new

        employee_service.update_name(id, params.name)
    rescue TypeError
        raise HTTP::BadRequest
    rescue
        raise HTTP::ErrorUnknown
    end
end

$router.register('DELETE', '/employees/:id') do |request|
    begin
        id = request.params[:id]

        raise HTTP::BadRequest if !id

        employee_service = Driving::EmployeeService.new

        employee_service.delete(id)
        
        nil
    rescue TypeError
        raise HTTP::BadRequest
    rescue
        raise HTTP::ErrorUnknown
    end
end
