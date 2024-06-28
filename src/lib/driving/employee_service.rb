# typed: strict
require 'ulid'
require 'json'
require_relative '../core/employee'
require_relative '../driven/employee_repository'

class EmployeeService
    include EmployeeDrivingPort
    extend T::Sig
    extend T::Helpers

    sig { void }
    def initialize
        @employee_repository = T.let(EmployeeRepository.new, EmployeeRepository)
    end

    sig { override.params(id: String).returns(String) }
    def read(id)
        employee = @employee_repository.read(id)
        serialize(employee)
    end

    sig { override.returns(String) }
    def read_collection
        employees = @employee_repository.read_collection
        serialize_collection(employees)
    end

    sig { override.params(name: String, birth: Date).returns(String) }
    def create(name, birth)
        id = ULID::generate
        employee = Employee.new(id, name, birth)
        employee = @employee_repository.save(employee)
        serialize(employee)
    end
  
    sig { override.params(id: String, name: String).returns(String) }
    def update_name(id, name)
        employee = @employee_repository.read(id)
        employee = employee.update_name(name)
        serialize(employee)
    end
  
    sig { override.params(id: String).void }
    def delete(id)
        @employee_repository.delete(id)
    end

    private

    sig { params(employee: Employee).returns(String) }
    def serialize(employee)
        {
            id: employee.id,
            name: employee.name,
            birth: employee.birth
        }.to_json
    end

    sig { params(employees: T::Array[Employee]).returns(String) }
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