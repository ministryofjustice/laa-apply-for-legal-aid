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
                  :additional_params,
                  :hearing_date_1i,
                  :hearing_date_2i,
                  :hearing_date_3i,
                  :limitation_note

    validates :accepted_emergency_defaults, presence: { unless: :draft? }
    validates :hearing_date, presence: true, if: :hearing_date_required?
    validates :hearing_date, date: true, allow_nil: true, if: :hearing_date_required?

    def initialize(*args)
      super
      @defaults = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(args.first[:model], true))
      self.emergency_level_of_service = @defaults.dig("default_level_of_service", "level")
      self.emergency_level_of_service_name = @defaults.dig("default_level_of_service", "name")
      self.emergency_level_of_service_stage = @defaults.dig("default_level_of_service", "stage")
      self.delegated_functions_scope_limitation_code = @defaults.dig("default_scope", "code")
      self.delegated_functions_scope_limitation_meaning = @defaults.dig("default_scope", "meaning")
      self.delegated_functions_scope_limitation_description = @defaults.dig("default_scope", "description")
      self.additional_params = @defaults.dig("default_scope", "additional_params")
    end

    def save
      return false unless valid?

      model.scope_limitations.where(scope_type: :emergency).destroy_all

      if accepted_emergency_defaults&.to_s == "false"
        attributes[:emergency_level_of_service] = nil
        attributes[:emergency_level_of_service_name] = nil
        attributes[:emergency_level_of_service_stage] = nil
      else
        model.update!(emergency_level_of_service:,
                      emergency_level_of_service_name:,
                      emergency_level_of_service_stage:)

        new_scope = {
          scope_type: :emergency,
          code: delegated_functions_scope_limitation_code,
          meaning: delegated_functions_scope_limitation_meaning,
          description: delegated_functions_scope_limitation_description,
        }
        new_scope[:hearing_date] = hearing_date if hearing_date.present?
        model.scope_limitations.create!(new_scope)
      end

      super
    end
    alias_method :save!, :save

    def hearing_date
      return @hearing_date if @hearing_date.present?
      return if hearing_date_fields.blank?
      return hearing_date_fields.input_field_values if hearing_date_fields.partially_complete? || hearing_date_fields.form_date_invalid?

      @hearing_date = attributes[:hearing_date] = hearing_date_fields.form_date
    end

    def hearing_date_fields
      @hearing_date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :hearing_date,
        prefix: :hearing_date_,
        suffix: :gov_uk,
      )
    end

  private

    def hearing_date_required?
      !draft? && accepted_emergency_defaults.to_s == "true" && additional_params.present?
    end

    def exclude_from_model
      %i[additional_params
         delegated_functions_scope_limitation_code
         delegated_functions_scope_limitation_meaning
         delegated_functions_scope_limitation_description
         hearing_date
         hearing_date_1i
         hearing_date_2i
         hearing_date_3i
         limitation_note]
    end
  end
end
