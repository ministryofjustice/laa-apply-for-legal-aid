module Providers
  module ProceedingMeritsTask
    class ParentalResponsibilitiesForm < BaseForm
      form_for Proceeding

      attr_accessor :relationship_to_child

      validates :relationship_to_child,
                inclusion: {
                  in: ["court_order", "parental_responsibility_agreement", ""],
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.parental_responsibilities.error"),
                },
                unless: :draft?
    end
  end
end
