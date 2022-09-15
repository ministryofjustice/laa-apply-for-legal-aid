module Proceedings
  class EmergencyDefaultsForm < BaseForm
    form_for Proceeding

    attr_accessor :accepted_emergency_defaults,
                  :emergency_level_of_service,
                  :emergency_level_of_service_name,
                  :emergency_level_of_service_stage,
                  :delegated_functions_scope_limitation_code,
                  :delegated_functions_scope_limitation_meaning,
                  :delegated_functions_scope_limitation_description,
                  :additional_params

    validates :accepted_emergency_defaults, presence: { unless: :draft? }

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model], true))
      self.emergency_level_of_service = @defaults["default_level_of_service"]["level"]
      self.emergency_level_of_service_name = @defaults["default_level_of_service"]["name"]
      self.emergency_level_of_service_stage = @defaults["default_level_of_service"]["stage"]
      self.delegated_functions_scope_limitation_code = @defaults["default_scope"]["code"]
      self.delegated_functions_scope_limitation_meaning = @defaults["default_scope"]["meaning"]
      self.delegated_functions_scope_limitation_description = @defaults["default_scope"]["description"]
      self.additional_params = @defaults["default_scope"]["additional_params"]
    end

    def save
      case accepted_emergency_defaults&.to_s
      when "false"
        attributes[:emergency_level_of_service] = nil
        attributes[:emergency_level_of_service_name] = nil
        attributes[:emergency_level_of_service_stage] = nil
      when "true"
        model.scope_limitations.create!(scope_type: :emergency,
                                        code: delegated_functions_scope_limitation_code,
                                        meaning: delegated_functions_scope_limitation_meaning,
                                        description: delegated_functions_scope_limitation_description)
      end
      super
    end

    def exclude_from_model
      %i[additional_params
         delegated_functions_scope_limitation_code
         delegated_functions_scope_limitation_meaning
         delegated_functions_scope_limitation_description]
    end
  end
end
