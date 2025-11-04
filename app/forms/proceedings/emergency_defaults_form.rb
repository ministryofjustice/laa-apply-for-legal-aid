module Proceedings
  class EmergencyDefaultsForm < BaseForm
    form_for Proceeding

    attr_accessor :accepted_emergency_defaults,
                  :emergency_level_of_service,
                  :emergency_level_of_service_name,
                  :emergency_level_of_service_stage,
                  :additional_params,
                  :hearing_date,
                  :limitation_note

    validates :accepted_emergency_defaults, presence: { unless: :draft? }
    validates :hearing_date, presence: true, if: :hearing_date_required?
    validates :hearing_date,
              date: {
                format: Date::DATE_FORMATS[:date_picker_parse_format],
                strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
              },
              allow_nil: true,
              if: :hearing_date_required?

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model], true))
      self.emergency_level_of_service = default_level_of_service["level"]
      self.emergency_level_of_service_name = default_level_of_service["name"]
      self.emergency_level_of_service_stage = default_level_of_service["stage"]
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
      return unless accepted_emergency_defaults_changed?

      model.scope_limitations.where(scope_type: :emergency).destroy_all

      if accepted_emergency_defaults&.to_s == "false"
        attributes[:emergency_level_of_service] = nil
        attributes[:emergency_level_of_service_name] = nil
        attributes[:emergency_level_of_service_stage] = nil
      else
        model.update!(emergency_level_of_service:,
                      emergency_level_of_service_name:,
                      emergency_level_of_service_stage:)

        model.scope_limitations.create!(scope_type: :emergency,
                                        code: default_scope["code"],
                                        meaning: default_scope["meaning"],
                                        description: default_scope["description"],
                                        hearing_date: hearing_date.presence)
      end

      super
    end
    alias_method :save!, :save

  private

    def accepted_emergency_defaults_changed?
      accepted_emergency_defaults.to_s != model.accepted_emergency_defaults.to_s
    end

    def hearing_date_required?
      !draft? &&
        accepted_emergency_defaults.to_s == "true" &&
        additional_params.filter_map { |p| p["name"] }.include?("hearing_date")
    end

    def exclude_from_model
      %i[additional_params
         hearing_date
         limitation_note]
    end
  end
end
