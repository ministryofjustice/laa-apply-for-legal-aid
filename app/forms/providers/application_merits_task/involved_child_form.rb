module Providers
  module ApplicationMeritsTask
    class InvolvedChildForm
      include BaseForm
      form_for ::ApplicationMeritsTask::InvolvedChild

      BASE_ATTRIBUTES = %i[full_name].freeze

      MODEL_ATTRIBUTES = BASE_ATTRIBUTES + %i[date_of_birth].freeze # Used in controller parameter handling

      ATTRIBUTES = BASE_ATTRIBUTES + %i[date_of_birth_1i date_of_birth_2i date_of_birth_3i].freeze

      SCOPE = 'activemodel.errors.models.application_merits_task.involved_child.attributes'.freeze

      attr_accessor(*ATTRIBUTES)
      attr_writer :date_of_birth

      validates :full_name, presence: true, unless: :draft?
      validates :date_of_birth, presence: true, unless: :draft_and_not_partially_complete_date?
      validates :date_of_birth, date: { not_in_the_future: true }, allow_nil: true

      def initialize(*args)
        super
        set_instance_variables_for_attributes_if_not_set_but_in_model(
          attrs: date_fields.fields,
          model_attributes: date_fields.model_attributes
        )
      end

      # Note that this method is first called by `validates`.
      # Without that validation, the functionality in this method will not be called before save
      def date_of_birth
        return @date_of_birth if @date_of_birth.present?
        return if date_fields.blank?
        return date_fields.input_field_values if date_fields.partially_complete? || date_fields.form_date_invalid?

        @date_of_birth = attributes[:date_of_birth] = date_fields.form_date
      end

      private

      def draft_and_not_partially_complete_date?
        draft? && !date_fields.partially_complete?
      end

      def exclude_from_model
        date_fields.fields
      end

      def date_fields
        @date_fields ||= DateFieldBuilder.new(
          form: self,
          model: model,
          method: :date_of_birth,
          prefix: :date_of_birth_,
          suffix: :gov_uk
        )
      end
    end
  end
end
