module Providers
  module ApplicationMeritsTask
    class BiologicalParentForm < BaseForm
      form_for Applicant

      attr_accessor :relationship_to_children

      validates :relationship_to_children,
                inclusion: {
                  in: %w[biological false],
                  message: I18n.t("providers.application_merits_task.relationship_to_children.biological_parent.error"),
                  allow_blank: true,
                },
                presence: {
                  message: I18n.t("providers.application_merits_task.relationship_to_children.biological_parent.error"),
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
