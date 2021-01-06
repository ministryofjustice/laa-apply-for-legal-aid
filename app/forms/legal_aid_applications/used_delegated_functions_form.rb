module LegalAidApplications
  class UsedDelegatedFunctionsForm
    include BaseForm
    form_for LegalAidApplication

    attr_accessor :used_delegated_functions_on_1i, :used_delegated_functions_on_2i,
                  :used_delegated_functions_on_3i, :used_delegated_functions
    attr_writer :used_delegated_functions_on

    validates :used_delegated_functions, presence: { unless: :draft? }
    validates :used_delegated_functions_on, presence: { unless: :date_not_required? }
    validates :used_delegated_functions_on, date: { not_in_the_future: true }, allow_nil: true
    validate :date_in_range
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

    def date_in_range
      return if date_not_required? || !datetime?(used_delegated_functions_on)
      return true if Time.zone.parse(used_delegated_functions_on.to_s) >= Date.current.ago(12.months)

      add_date_in_range_error
    end

    def datetime?(value)
      value.methods.include? :strftime
    end

    def add_date_in_range_error
      translation_path = 'activemodel.errors.models.legal_aid_application.attributes.used_delegated_functions_on.date_not_in_range'
      errors.add(:used_delegated_functions, I18n.t(translation_path, months: Time.zone.now.ago(12.months).strftime('%d %m %Y')))
    end

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
        prefix: :used_delegated_functions_on_,
        suffix: :gov_uk
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
