module Proceedings
  class SubstantiveLevelOfServiceForm < BaseForm
    form_for Proceeding

    attr_accessor :substantive_level_of_service,
                  :levels_of_service

    validates :substantive_level_of_service, presence: { unless: :draft? }

    def exclude_from_model
      [:levels_of_service]
    end

    def initialize(*args)
      super
      self.levels_of_service = LegalFramework::ProceedingTypes::Proceeding.call(args.first[:model].ccms_code).service_levels
    end

    def save
      return false unless valid?

      level = levels_of_service.find { |lvl| lvl["level"] == substantive_level_of_service.to_i }
      attributes[:substantive_level_of_service_name] = level["name"]
      attributes[:substantive_level_of_service_stage] = level["stage"]
      super
    end
    alias_method :save!, :save
  end
end
