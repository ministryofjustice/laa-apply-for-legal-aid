module Proceedings
  class SubstantiveDefaultsForm < BaseForm
    form_for Proceeding

    # TODO: dated 3 OCT 2022 @colinbruce Additional data requirements
    # The full method of handling additional data was not implemented for substantive defaults
    # this is because at the time of writing, no default substantive proceedings had additional
    # data requirements.  If at some point in the future, a new category of law that requires
    # it is  implemented, the functionality can be duplicated from the emergency_defaults form

    attr_accessor :accepted_substantive_defaults,
                  :additional_params

    validates :accepted_substantive_defaults, presence: true, unless: :draft?

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model], false))
      self.additional_params = default_scope["additional_params"]
    end

    def default_level_of_service
      @default_level_of_service ||= @defaults["default_level_of_service"]
    end

    def default_scope
      @default_scope ||= @defaults["default_scope"]
    end

    def save
      return false unless valid?
      return unless accepted_substantive_defaults_changed?

      model.scope_limitations.where(scope_type: :substantive).destroy_all

      if accepted_substantive_defaults&.to_s == "false"
        attributes[:substantive_level_of_service] = nil
        attributes[:substantive_level_of_service_name] = nil
        attributes[:substantive_level_of_service_stage] = nil
      else
        attributes[:substantive_level_of_service] = default_level_of_service["level"]
        attributes[:substantive_level_of_service_name] = default_level_of_service["name"]
        attributes[:substantive_level_of_service_stage] = default_level_of_service["stage"]

        model.scope_limitations.create!(scope_type: :substantive,
                                        code: default_scope["code"],
                                        meaning: default_scope["meaning"],
                                        description: default_scope["description"])
      end

      super
    end
    alias_method :save!, :save

    def exclude_from_model
      %i[additional_params]
    end

  private

    def accepted_substantive_defaults_changed?
      accepted_substantive_defaults.to_s != model.accepted_substantive_defaults.to_s
    end
  end
end
