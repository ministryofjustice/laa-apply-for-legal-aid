module LegalAidApplications
  class UsedDelegatedFunctionsForm
    include BaseForm
    form_for LegalAidApplication

    attr_accessor :used_delegated_functions_year, :used_delegated_functions_month,
                  :used_delegated_functions_day, :used_delegated_functions
    attr_writer :used_delegated_functions_on

    validates :used_delegated_functions, presence: { unless: :draft? }
    validates :used_delegated_functions_on, presence: { unless: :date_not_required? }
    validates :used_delegated_functions_on, date: { not_in_the_future: true }, allow_nil: true
    validates :used_delegated_functions_reported_on, presence: { unless: :date_not_required? }

    after_validation :update_substantive_application_deadline

    def initialize(*args)
      super
      attributes[:used_delegated_functions_reported_on] = used_delegated_functions_reported_on
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes
      )
    end

    # Note that this method is first called by `validates`.
    # Without that validation, the functionality in this method will not be called before save
    def used_delegated_functions_on
      return delete_existing_date unless used_delegated_functions_selected?
      return @used_delegated_functions_on if @used_delegated_functions_on.present?
      return if date_fields.blank?
      return :invalid if date_fields.partially_complete? || date_fields.form_date_invalid?

      @used_delegated_functions_on = attributes[:used_delegated_functions_on] = date_fields.form_date
    end

    def used_delegated_functions_reported_on
      @used_delegated_functions_reported_on = used_delegated_functions_selected? ? Date.today : nil
    end

    private

    def date_not_required?
      !used_delegated_functions_selected? || draft_and_not_partially_complete_date?
    end

    def used_delegated_functions_selected?
      ActiveModel::Type::Boolean.new.cast(used_delegated_functions)
    end

    def exclude_from_model
      date_fields.fields
    end

    def draft_and_not_partially_complete_date?
      draft? && !date_fields.partially_complete?
    end

    def delete_existing_date
      model.used_delegated_functions_on = nil
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :used_delegated_functions_on,
        prefix: :used_delegated_functions_
      )
    end

    def substantive_application_deadline
      return unless used_delegated_functions_on && used_delegated_functions_on != :invalid

      SubstantiveApplicationDeadlineCalculator.call self
    end

    def update_substantive_application_deadline
      model.substantive_application_deadline_on = substantive_application_deadline
    end
  end
end
