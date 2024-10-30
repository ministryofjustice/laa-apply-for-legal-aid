module Reports::Merits
  class DelegatedFunctionsComponent < ViewComponent::Base
    with_collection_parameter :proceeding

    def initialize(proceeding:)
      @proceeding = proceeding
      super
    end

  private

    def rows
      [
        row(t(".date_reported"), date_reported),
        row(t(".date_used"), date_used),
        row(t(".days_to_report"), days_to_report),
      ]
    end

    def row(key, value)
      {
        key: { text: key, classes: "govuk-!-width-one-half" },
        value: { text: value },
      }
    end

    def date_reported
      l(@proceeding.used_delegated_functions_reported_on, format: :long_date)
    end

    def date_used
      l(@proceeding.used_delegated_functions_on, format: :long_date)
    end

    def days_to_report
      distance_of_time_in_words(
        @proceeding.used_delegated_functions_reported_on,
        @proceeding.used_delegated_functions_on,
      )
    end
  end
end
