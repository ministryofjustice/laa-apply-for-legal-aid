module Providers
  module ApplicationMeritsTask
    class MatterOpposedReasonForm < BaseForm
      form_for ::ApplicationMeritsTask::MatterOpposition

      attr_accessor :reason, :legal_aid_application_id

      validates :reason, :legal_aid_application_id, presence: true
    end
  end
end
