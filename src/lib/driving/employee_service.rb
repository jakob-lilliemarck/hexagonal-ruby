# typed: strict

require 'ulid'
require_relative '../core/employee_model'

module Driving
  class EmployeeService
    include Core::EmployeeDrivingPort
    extend T::Sig
    extend T::Helpers

    sig { params(repository: Core::EmployeeDrivenPort).void }
    def initialize(repository)
      @employee_repository = T.let(repository, Core::EmployeeDrivenPort)
    end

    sig { override.params(id: String).returns(Core::Employee) }
    def read(id)
      @employee_repository.read(id)
    end

    sig { override.returns(T::Array[Core::Employee]) }
    def read_collection
      @employee_repository.read_collection
    end

    sig { override.params(name: String, birth: Date).returns(Core::Employee) }
    def create(name, birth)
      id = ULID.generate
      employee = Core::Employee.new(id, name, birth)
      @employee_repository.save(employee)
    end

    sig { override.params(id: String, name: String).returns(Core::Employee) }
    def update_name(id, name)
      employee = @employee_repository.read(id)
      employee.update_name(name)
    end

    sig { override.params(id: String).void }
    def delete(id)
      @employee_repository.delete(id)
    end
  end
end
