module LegalAidApplications
  class EmergencyCostOverrideForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :emergency_cost_override, :emergency_cost_requested, :emergency_cost_reasons

    validates :emergency_cost_override, presence: true, unless: :draft?
    validates :emergency_cost_reasons, presence: true, if: :requested_override?
    validates(
      :emergency_cost_requested,
      currency: { greater_than_or_equal_to: 0, allow_blank: true },
      presence: { unless: :draft? },
      if: :requested_override?
    )

    def requested_override?
      emergency_cost_override.to_s == 'true'
    end

    # =-=-=-=-=-=-= old version -=-=-=-=-=-=-
    # attr_accessor :payment_remaining, :payments_remain
    #
    # validates :payments_remain, presence: true, unless: :draft?
    # validates(
    #   :payment_remaining,
    #   currency: { greater_than_or_equal_to: 0, allow_blank: true },
    #   presence: { unless: :draft? },
    #   if: :payments_remain?
    # )
    #
    # def payments_remain?
    #   payments_remain.to_s == 'true'
    # end
    #
    # def save
    #   attributes[:payment_remaining] = 0 if valid? && !payments_remain?
    #   super
    # end
    #
    # private
    #
    # def exclude_from_model
    #   [:payments_remain]
    # end
    #
    # def attributes_to_clean
    #   [:payment_remaining]
    # end
  end
end
