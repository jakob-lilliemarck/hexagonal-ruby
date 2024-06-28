# typed: strict
require 'date'
require_relative '../core/employee'

$employees = {}

class RecordNotFound < StandardError
    extend T::Sig

    sig { params(id: String).void }
    def initialize(id)
      super("Record not found: #{id}")
    end
end

class EmployeeRepository
    extend T::Sig
    extend T::Helpers
    include EmployeeDrivenPort

    sig { void }
    def initialize
        @employees = T.let($employees, T::Hash[String, Employee])
    end

    sig { override.params(id: String).returns(Employee) }
    def read(id)
        employee = @employees[id]
        raise RecordNotFound.new(id) if !employee
        employee
    end
  
    sig { override.returns(T::Array[Employee]) }
    def read_collection
        @employees.values
    end
  
    sig { override.params(employee: Employee).returns(Employee) }
    def save(employee)
        @employees[employee.id] = employee
        employee
    end

    sig { override.params(id: String).void }
    def delete(id)
        @employees.delete(id)
    end
end

