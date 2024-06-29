# typed: strict

require 'sorbet-runtime'

module Core
  class Employee
    extend T::Sig

    sig { returns(String) }
    attr_reader :id

    sig { returns(String) }
    attr_reader :name

    sig { returns(Date) }
    attr_reader :birth

    sig { params(id: String, name: String, birth: Date).void }
    def initialize(id, name, birth)
      @id = id
      @name = name
      @birth = birth
    end

    sig { params(name: String).returns(T.self_type) }
    def update_name(name)
      @name = name
      self
    end
  end

  module EmployeeDrivingPort
    extend T::Sig
    extend T::Helpers
    interface!

    sig { abstract.params(id: String).returns(Employee) }
    def read(id); end

    sig { abstract.returns(T::Array[Employee]) }
    def read_collection; end

    sig { abstract.params(name: String, birth: Date).returns(Employee) }
    def create(name, birth); end

    sig { abstract.params(id: String, name: String).returns(Employee) }
    def update_name(id, name); end

    sig { abstract.params(id: String).void }
    def delete(id); end
  end

  module EmployeeDrivenPort
    extend T::Sig
    extend T::Helpers
    interface!

    sig { abstract.params(id: String).returns(Employee) }
    def read(id); end

    sig { abstract.returns(T::Array[Employee]) }
    def read_collection; end

    sig { abstract.params(employee: Employee).returns(Employee) }
    def save(employee); end

    sig { abstract.params(id: String).void }
    def delete(id); end
  end
end
