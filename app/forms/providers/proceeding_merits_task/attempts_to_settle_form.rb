module Providers
  module ProceedingMeritsTask
    class AttemptsToSettleForm
      include BaseForm

      form_for ::ProceedingMeritsTask::AttemptsToSettle

      attr_accessor :attempts_made

      validate :attempts_made_present?

      def attempts_made_present?
        errors.add :attempts_made, error_message if attempts_made.blank?
      end

      def error_message
        I18n.t('providers.proceeding_merits_task.attempts_to_settle.show.error')
      end
    end
  end
end
