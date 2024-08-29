module Proceedings
  class SubstantiveDefaultsForm < BaseForm
    form_for Proceeding

    # TODO: dated 3 OCT 2022 @colinbruce Additional data requirements
    # The full method of handling additional data was not implemented for substantive defaults
    # this is because at the time of writing, no default substantive proceedings had additional
    # data requirements.  If at some point in the future, a new category of law that requires
    # it is  implemented, the functionality can be duplicated from the emergency_defaults form

    attr_accessor :accepted_substantive_defaults,
                  :substantive_level_of_service,
                  :substantive_level_of_service_name,
                  :substantive_level_of_service_stage,
                  :substantive_scope_limitation_meaning,
                  :substantive_scope_limitation_description,
                  :substantive_scope_limitation_code,
                  :additional_params

    validates :accepted_substantive_defaults, presence: true, unless: proc { draft? || model.special_childrens_act? }

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model], false))
      self.substantive_level_of_service = @defaults["default_level_of_service"]["level"]
      self.substantive_level_of_service_name = @defaults["default_level_of_service"]["name"]
      self.substantive_level_of_service_stage = @defaults["default_level_of_service"]["stage"]
      self.substantive_scope_limitation_meaning = @defaults["default_scope"]["meaning"]
      self.substantive_scope_limitation_description = @defaults["default_scope"]["description"]
      self.substantive_scope_limitation_code = @defaults["default_scope"]["code"]
      self.additional_params = @defaults["default_scope"]["additional_params"]
    end

    def save
      return false unless valid?

      model.scope_limitations.where(scope_type: :substantive).destroy_all
      if accepted_substantive_defaults&.to_s == "false"
        attributes[:substantive_level_of_service] = nil
        attributes[:substantive_level_of_service_name] = nil
        attributes[:substantive_level_of_service_stage] = nil
      else
        model.update!(substantive_level_of_service:,
                      substantive_level_of_service_name:,
                      substantive_level_of_service_stage:)
        model.scope_limitations.create!(scope_type: :substantive,
                                        code: substantive_scope_limitation_code,
                                        meaning: substantive_scope_limitation_meaning,
                                        description: substantive_scope_limitation_description)
      end
      super
    end
    alias_method :save!, :save

    def exclude_from_model
      %i[additional_params
         substantive_scope_limitation_code
         substantive_scope_limitation_meaning
         substantive_scope_limitation_description]
    end
  end
end
