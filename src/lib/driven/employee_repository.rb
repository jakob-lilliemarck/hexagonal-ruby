# typed: strict
require 'date'
require_relative '../core/employee'

$employees = {}

module Driven
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
        include Core::EmployeeDrivenPort
    
        sig { void }
        def initialize
            @employees = T.let($employees, T::Hash[String, Core::Employee])
        end
    
        sig { override.params(id: String).returns(Core::Employee) }
        def read(id)
            employee = @employees[id]
            raise RecordNotFound.new(id) if !employee
            employee
        end
    
        sig { override.returns(T::Array[Core::Employee]) }
        def read_collection
            @employees.values
        end
    
        sig { override.params(employee: Core::Employee).returns(Core::Employee) }
        def save(employee)
            @employees[employee.id] = employee
            employee
        end
    
        sig { override.params(id: String).void }
        def delete(id)
            @employees.delete(id)
        end
    end
end