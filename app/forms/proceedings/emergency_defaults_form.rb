module Proceedings
  class EmergencyDefaultsForm < BaseForm
    form_for Proceeding

    attr_accessor :accepted_emergency_defaults,
                  :emergency_level_of_service,
                  :emergency_level_of_service_name,
                  :emergency_level_of_service_stage,
                  :delegated_functions_scope_limitation_code,
                  :delegated_functions_scope_limitation_meaning,
                  :delegated_functions_scope_limitation_description

    validates :accepted_emergency_defaults, presence: { unless: :draft? }

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model]))
      self.emergency_level_of_service = @defaults["default_level_of_service"]["level"]
      self.emergency_level_of_service_name = @defaults["default_level_of_service"]["name"]
      self.emergency_level_of_service_stage = @defaults["default_level_of_service"]["stage"]
      self.delegated_functions_scope_limitation_code = @defaults["default_scope"]["code"]
      self.delegated_functions_scope_limitation_meaning = @defaults["default_scope"]["meaning"]
      self.delegated_functions_scope_limitation_description = @defaults["default_scope"]["description"]
    end

    def save
      if accepted_emergency_defaults&.to_s == "false"
        attributes[:emergency_level_of_service] = nil
        attributes[:emergency_level_of_service_name] = nil
        attributes[:emergency_level_of_service_stage] = nil
        attributes[:delegated_functions_scope_limitation_code] = nil
        attributes[:delegated_functions_scope_limitation_meaning] = nil
        attributes[:delegated_functions_scope_limitation_description] = nil
      end
      super
    end
  end
end
