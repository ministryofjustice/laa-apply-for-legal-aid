module LegalFramework
  class SerializableMeritsTask
    attr_reader :name, :state, :dependencies

    def initialize(name, dependencies: [])
      @name = name
      @dependencies = dependencies
      @state = @dependencies.any? ? :waiting_for_dependency : :not_started
    end

    def remove_dependency(dependency_name)
      @dependencies.delete(dependency_name.to_sym)
      @dependencies.delete(dependency_name.to_s)

      @state = :not_started if @dependencies.empty?
    end

    def mark_as_complete!
      raise "Unmet dependency #{@dependencies.join(',')} for task #{@name}" if @dependencies.any?

      @state = :complete
    end
  end
end
