module Proceedings
  class SubstantiveDefaultsForm < BaseForm
    form_for Proceeding

    attr_accessor :accepted_substantive_defaults,
                  :substantive_level_of_service,
                  :substantive_level_of_service_name,
                  :substantive_level_of_service_stage,
                  :substantive_scope_limitation_meaning,
                  :substantive_scope_limitation_description,
                  :substantive_scope_limitation_code

    validates :accepted_substantive_defaults, presence: { unless: :draft? }

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model]))
      self.substantive_level_of_service = @defaults["default_level_of_service"]["level"]
      self.substantive_level_of_service_name = @defaults["default_level_of_service"]["name"]
      self.substantive_level_of_service_stage = @defaults["default_level_of_service"]["stage"]
      self.substantive_scope_limitation_meaning = @defaults["default_scope"]["meaning"]
      self.substantive_scope_limitation_description = @defaults["default_scope"]["description"]
      self.substantive_scope_limitation_code = @defaults["default_scope"]["code"]
    end

    def save
      if accepted_substantive_defaults&.to_s == "false"
        attributes[:substantive_level_of_service] = nil
        attributes[:substantive_level_of_service_name] = nil
        attributes[:substantive_level_of_service_stage] = nil
        attributes[:substantive_scope_limitation_meaning] = nil
        attributes[:substantive_scope_limitation_description] = nil
        attributes[:substantive_scope_limitation_code] = nil
      end
      super
    end
  end
end
