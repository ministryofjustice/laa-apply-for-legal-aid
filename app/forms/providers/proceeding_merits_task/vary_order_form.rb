module Providers
  module ProceedingMeritsTask
    class VaryOrderForm < BaseForm
      form_for ::ProceedingMeritsTask::VaryOrder

      attr_accessor :details, :proceeding_id

      validates :details, presence: true
    end
  end
end
