module LegalAidApplications
  class EmergencyCostOverrideForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :emergency_cost_override, :emergency_cost_requested, :emergency_cost_reasons,
                  :substantive_cost_override, :substantive_cost_requested, :substantive_cost_reasons

    validates :emergency_cost_override, inclusion: [true, false, "true", "false"], unless: :emergency_ignorable?
    validates :emergency_cost_reasons, presence: true, if: :requested_emergency_override?
    validates(
      :emergency_cost_requested,
      currency: { greater_than_or_equal_to: 0, allow_blank: true },
      presence: { unless: :draft? },
      if: :requested_emergency_override?,
    )

    validates :substantive_cost_override, inclusion: [true, false, "true", "false"], unless: :substantive_ignorable?
    validates :substantive_cost_reasons, presence: true, if: :requested_substantive_override?
    validates(
      :substantive_cost_requested,
      currency: { greater_than_or_equal_to: 0, less_than_or_equal_to: 25_000, allow_blank: true },
      presence: { unless: :draft? },
      if: :requested_substantive_override?,
    )

    def emergency_ignorable?
      draft? || !model.used_delegated_functions?
    end

    def substantive_ignorable?
      draft? || !model.substantive_cost_overridable?
    end

    def requested_emergency_override?
      emergency_cost_override.to_s == "true"
    end

    def requested_substantive_override?
      substantive_cost_override.to_s == "true"
    end

    def attributes_to_clean
      %i[emergency_cost_requested substantive_cost_requested]
    end
  end
end
