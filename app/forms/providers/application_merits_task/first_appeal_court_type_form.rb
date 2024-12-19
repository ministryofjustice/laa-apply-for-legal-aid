module Providers
  module ApplicationMeritsTask
    class FirstAppealCourtTypeForm < BaseAppealCourtTypeForm
      form_for ::ApplicationMeritsTask::Appeal

      attr_accessor :court_type

      validates :court_type, presence: true, inclusion: { in: FIRST_APPEAL_COURT_TYPES }, unless: :draft?

      def court_types
        FIRST_APPEAL_COURT_TYPES
      end
    end
  end
end
