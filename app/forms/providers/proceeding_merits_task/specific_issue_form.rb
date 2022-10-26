module Providers
  module ProceedingMeritsTask
    class SpecificIssueForm < BaseForm
      form_for ::ProceedingMeritsTask::SpecificIssue

      attr_accessor :confirmed, :details, :proceeding_id

      validates :details, :confirmed, presence: true
    end
  end
end
