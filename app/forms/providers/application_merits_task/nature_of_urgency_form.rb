module Providers
  module ApplicationMeritsTask
    class NatureOfUrgencyForm < BaseForm
      form_for ::ApplicationMeritsTask::Urgency

      attr_accessor :nature_of_urgency,
                    :hearing_date_set,
                    :hearing_date

      validates :nature_of_urgency,
                :hearing_date_set,
                presence: true,
                unless: :draft?

      validates :hearing_date, presence: true, if: :hearing_date_required?

      validates :hearing_date,
                date: {
                  format: Date::DATE_FORMATS[:date_picker_parse_format],
                  strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
                },
                allow_nil: true,
                if: :hearing_date_required?

      before_validation :clear_hearing_date, unless: :hearing_date_required?

    private

      def clear_hearing_date
        attributes[:hearing_date] = nil
      end

      def hearing_date_required?
        !draft? && hearing_date_set.to_s == "true"
      end
    end
  end
end
