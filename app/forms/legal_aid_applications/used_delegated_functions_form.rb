module LegalAidApplications
  class UsedDelegatedFunctionsForm
    include BaseForm
    form_for LegalAidApplication

    attr_accessor :used_delegated_functions_year, :used_delegated_functions_month,
                  :used_delegated_functions_day
    attr_writer :used_delegated_functions_on

    validates :used_delegated_functions_on, presence: true, unless: :draft_and_not_partially_complete_date?
    validates :used_delegated_functions_on, date: { not_in_the_future: true }, allow_nil: true

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes
      )
    end

    # Note that this method is first called by `validates`.
    # Without that validation, the functionality in this method will not be called before save
    def used_delegated_functions_on
      return @used_delegated_functions_on if @used_delegated_functions_on.present?
      return if date_fields.blank?
      return :invalid if date_fields.partially_complete? || date_fields.form_date_invalid?

      @used_delegated_functions_on = attributes[:used_delegated_functions_on] = date_fields.form_date
    end

    private

    def exclude_from_model
      date_fields.fields
    end

    def draft_and_not_partially_complete_date?
      draft? && !date_fields.partially_complete?
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :used_delegated_functions_on,
        prefix: :used_delegated_functions_
      )
    end
  end
end
