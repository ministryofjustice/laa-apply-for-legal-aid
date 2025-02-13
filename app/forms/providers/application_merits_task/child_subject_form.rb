module Providers
  module ApplicationMeritsTask
    class ChildSubjectForm < BaseForm
      form_for Applicant

      attr_accessor :relationship_to_children

      validates :relationship_to_children,
                inclusion: {
                  in: %w[child_subject false],
                  message: I18n.t("providers.application_merits_task.relationship_to_children.child_subject.error"),
                  allow_blank: true,
                },
                presence: {
                  message: I18n.t("providers.application_merits_task.relationship_to_children.child_subject.error"),
                },
                unless: :draft?
      def save
        return model.update!(relationship_to_children: nil) if relationship_to_children.eql?("false")

        super
      end
      alias_method :save!, :save
    end
  end
end
