module Providers
  module ProceedingMeritsTask
    class BiologicalParentForm < BaseForm
      form_for Proceeding

      attr_accessor :relationship_to_child

      validates :relationship_to_child,
                inclusion: {
                  in: %w[biological false],
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.biological_parent.error"),
                  allow_blank: true,
                },
                presence: {
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.biological_parent.error"),
                },
                unless: :draft?

      def save
        self.relationship_to_child = nil if relationship_to_child.eql?("false")
        super
      end
      alias_method :save!, :save
    end
  end
end
