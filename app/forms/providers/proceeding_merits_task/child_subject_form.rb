module Providers
  module ProceedingMeritsTask
    class ChildSubjectForm < BaseForm
      form_for Proceeding

      attr_accessor :child_subject
    end
  end
end
