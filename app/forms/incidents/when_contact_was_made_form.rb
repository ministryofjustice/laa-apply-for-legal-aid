module Incidents
  class WhenContactWasMadeForm < BaseForm
    form_for ApplicationMeritsTask::Incident

    attr_accessor :first_contact_date_1i, :first_contact_date_2i, :first_contact_date_3i
    attr_writer :first_contact_date

    validates :first_contact_date, presence: true, unless: :draft_and_not_partially_complete_first_contact_date?
    validates :first_contact_date, date: { not_in_the_future: true }, allow_nil: true

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: first_contact_date_fields.fields,
        model_attributes:
        [
          first_contact_date_fields.model_attributes,
        ].compact.reduce(&:merge),
      )
    end

    def first_contact_date
      return @first_contact_date if @first_contact_date.present?
      return if first_contact_date_fields.blank?
      return first_contact_date_fields.input_field_values if first_contact_date_incomplete?

      @first_contact_date = attributes[:first_contact_date] = first_contact_date_fields.form_date
    end

  private

    def first_contact_date_incomplete?
      first_contact_date_fields.partially_complete? || first_contact_date_fields.form_date_invalid?
    end

    def exclude_from_model
      first_contact_date_fields.fields
    end

    def draft_and_not_partially_complete_first_contact_date?
      draft? && !first_contact_date_fields.partially_complete?
    end

    def first_contact_date_fields
      @first_contact_date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :first_contact_date,
        prefix: :first_contact_date_,
        suffix: :gov_uk,
      )
    end
  end
end
