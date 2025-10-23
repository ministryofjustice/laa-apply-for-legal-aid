module Proceedings
  class DelegatedFunctionsForm < BaseForm
    form_for Proceeding

    attr_accessor :used_delegated_functions, :used_delegated_functions_on

    validates :used_delegated_functions, presence: true, unless: :draft?

    validates :used_delegated_functions_on,
              date: {
                format: Date::DATE_FORMATS[:date_picker_parse_format],
                strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
                not_in_the_future: true,
                earliest_allowed_date: { date: 12.months.ago.to_date.strftime(Date::DATE_FORMATS[:date_picker_parse_format]) },
              },
              if: :used_delegated_functions_on_presence_required?

    def save
      if used_delegated_functions&.to_s == "true"
        attributes[:used_delegated_functions_reported_on] = Time.zone.today
      else
        attributes[:used_delegated_functions_reported_on] = nil
        attributes[:used_delegated_functions_on] = nil
      end
      super
    end
    alias_method :save!, :save

  private

    def used_delegated_functions_on_presence_required?
      return false if used_delegated_functions.to_s == "false" || draft?

      true
    end
  end
end
