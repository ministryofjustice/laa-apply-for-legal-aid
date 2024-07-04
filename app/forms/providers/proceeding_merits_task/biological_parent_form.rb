module Providers
  module ProceedingMeritsTask
    class BiologicalParentForm < BaseForm
      form_for Proceeding

      attr_accessor :relationship_to_child

      validates :relationship_to_child,
                inclusion: {
                  in: ["biological", ""],
                  message: I18n.t("providers.proceeding_merits_task.relationship_to_child.biological_parent.error"),
                },
                unless: :draft?
    end
  end
end
