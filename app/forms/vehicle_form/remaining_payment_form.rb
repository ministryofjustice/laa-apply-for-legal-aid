module VehicleForm
  class RemainingPaymentForm
    include BaseForm

    form_for Vehicle

    attr_accessor :payment_remaining, :payments_remain

    validates :payments_remain, presence: true, unless: :draft?
    validates(
      :payment_remaining,
      currency: { greater_than_or_equal_to: 0, allow_blank: true },
      presence: { unless: :draft? },
      if: :payments_remain?
    )

    def payments_remain?
      payments_remain.to_s == 'true'
    end

    def save
      attributes[:payment_remaining] = 0 if valid? && !payments_remain?
      super
    end

    private

    def exclude_from_model
      [:payments_remain]
    end

    def attributes_to_clean
      [:payment_remaining]
    end
  end
end
