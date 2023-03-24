module DateOfBirthHandling
  extend ActiveSupport::Concern

  included do
    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: dob_date_fields.fields,
        model_attributes: dob_date_fields.model_attributes,
      )
    end

    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return if dob_date_fields.blank?
      return dob_date_fields.input_field_values if dob_date_fields.partially_complete? || dob_date_fields.form_date_invalid?

      @date_of_birth = attributes[:date_of_birth] = dob_date_fields.form_date
    end

    def exclude_from_model
      dob_date_fields.fields
    end

    def draft_and_not_partially_complete_date_of_birth?
      draft? && !dob_date_fields.partially_complete?
    end

    def dob_date_fields
      @dob_date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :date_of_birth,
        prefix: :date_of_birth_,
        suffix: :gov_uk,
      )
    end
  end
end
