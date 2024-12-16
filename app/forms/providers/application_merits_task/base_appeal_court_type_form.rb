module Providers
  module ApplicationMeritsTask
    class BaseAppealCourtTypeForm < BaseForm
      SECOND_APPEAL_COURT_TYPES = %w[
        court_of_appeal
        supreme_court
      ].freeze

      FIRST_APPEAL_COURT_TYPES =
        SECOND_APPEAL_COURT_TYPES + %w[
          other_court
        ].freeze

      # :nocov:
      def court_types
        raise "Implement in subclass"
      end
      # :nocov:
    end
  end
end
