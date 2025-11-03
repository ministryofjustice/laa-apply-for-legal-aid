module Proceedings
  module ProceedingLoopResettable
    extend ActiveSupport::Concern

    included do
    private

        def reset_proceeding_loop
          model.update!(
            accepted_emergency_defaults: nil,
            accepted_substantive_defaults: nil,
          )

          model.legal_aid_application.update!(
            emergency_cost_override: nil,
            emergency_cost_requested: nil,
            emergency_cost_reasons: nil,
            substantive_cost_override: nil,
            substantive_cost_requested: nil,
            substantive_cost_reasons: nil,
          )

          model.scope_limitations.destroy_all
        end
    end
  end
end
