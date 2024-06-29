# typed: strict
# frozen_string_literal: true

require 'date'
require_relative '../core/employee_model'

# In memory mocked database table
# rubocop:disable Style/GlobalVars
$employees = {}
# rubocop:enable Style/GlobalVars

module Driven
  module Errors
    # Error raised when a searched record could not be found
    class RecordNotFound < StandardError
      extend T::Sig

      sig { params(id: String).void }
      def initialize(id)
        super("Record not found: #{id}")
      end
    end
  end

  # Employee repository implementing the EmployeeDrivenPort
  # Responsible for loading and saving employees
  class EmployeeRepository
    extend T::Sig
    extend T::Helpers
    include Core::EmployeeDrivenPort

    sig { void }
    def initialize
      # rubocop:disable Style/GlobalVars
      @employees = T.let($employees, T::Hash[String, Core::Employee])
      # rubocop:enable Style/GlobalVars
    end

    sig { override.params(id: String).returns(Core::Employee) }
    def read(id)
      employee = @employees[id]
      raise Errors::RecordNotFound, id unless employee

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
