module Providers
  module ApplicationMeritsTask
    class NatureOfUrgencyForm < BaseForm
      form_for ::ApplicationMeritsTask::Urgency

      attr_accessor :nature_of_urgency,
                    :hearing_date_set,
                    :hearing_date_1i,
                    :hearing_date_2i,
                    :hearing_date_3i

      attr_writer :hearing_date

      validates :nature_of_urgency,
                :hearing_date_set,
                presence: true,
                unless: :draft?

      validates :hearing_date, presence: true, if: :hearing_date_required?
      validates :hearing_date, date: true, allow_nil: true, if: :hearing_date_required?

      def initialize(*args)
        super
        set_instance_variables_for_attributes_if_not_set_but_in_model(
          attrs: hearing_date_fields.fields,
          model_attributes: hearing_date_fields.model_attributes,
        )
      end

      def hearing_date
        return @hearing_date if @hearing_date.present?
        return if hearing_date_fields.blank?
        return hearing_date_fields.input_field_values if hearing_date_fields.partially_complete? || hearing_date_fields.form_date_invalid?

        @hearing_date = attributes[:hearing_date] = hearing_date_fields.form_date
      end

      def save
        unless hearing_date_required?
          hearing_date_1i&.clear
          hearing_date_2i&.clear
          hearing_date_3i&.clear
          @hearing_date = attributes[:hearing_date] = nil
        end
        super
      end
      alias_method :save!, :save

    private

      def hearing_date_required?
        !draft? && hearing_date_set.to_s == "true"
      end

      def exclude_from_model
        hearing_date_fields.fields
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
    end
  end
end
