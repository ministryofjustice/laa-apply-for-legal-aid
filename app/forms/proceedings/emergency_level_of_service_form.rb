module Proceedings
  class EmergencyLevelOfServiceForm < BaseForm
    form_for Proceeding

    attr_accessor :emergency_level_of_service,
                  :levels_of_service

    validates :emergency_level_of_service, presence: true, unless: :draft?

    def exclude_from_model
      [:levels_of_service]
    end

    def initialize(*args)
      @levels_of_service = args.first[:los]
      @levels_of_service.deep_stringify_keys! if @levels_of_service.is_a?(Hash) # not needed
      args.first.delete(:los)
      super
    end

    def save
      return false unless valid?

      level = levels_of_service.find { |lvl| lvl["level"] == emergency_level_of_service.to_i }
      attributes[:emergency_level_of_service_name] = level["name"]
      attributes[:emergency_level_of_service_stage] = level["stage"]
      super
    end
    alias_method :save!, :save
  end
end
