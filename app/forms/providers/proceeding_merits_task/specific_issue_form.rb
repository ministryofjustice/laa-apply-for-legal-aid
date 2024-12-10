module Providers
  module ProceedingMeritsTask
    class SpecificIssueForm < BaseForm
      form_for ::ProceedingMeritsTask::SpecificIssue

      attr_accessor :details, :proceeding_id

      validates :details, presence: true
    end
  end
end
