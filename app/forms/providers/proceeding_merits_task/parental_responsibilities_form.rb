module Providers
  module ProceedingMeritsTask
    class ParentalResponsibilitiesForm < BaseForm
      form_for Proceeding

      attr_accessor :relationship_to_child

      validates :relationship_to_child,
                inclusion: {
                  in: %w[court_order parental_responsibility_agreement false],
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.parental_responsibilities.error"),
                  allow_blank: true,
                },
                presence: {
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.parental_responsibilities.error"),
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
