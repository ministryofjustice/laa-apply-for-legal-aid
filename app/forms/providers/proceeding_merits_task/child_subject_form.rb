module Providers
  module ProceedingMeritsTask
    class ChildSubjectForm < BaseForm
      form_for Proceeding

      attr_accessor :relationship_to_child

      validates :relationship_to_child,
                inclusion: {
                  in: %w[child_subject false],
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.child_subject.error"),
                  allow_blank: true,
                },
                presence: {
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.child_subject.error"),
                },
                unless: :draft?
      def save
        return model.update!(relationship_to_child: nil) if relationship_to_child.eql?("false")

        super
      end
      alias_method :save!, :save
    end
  end
end
