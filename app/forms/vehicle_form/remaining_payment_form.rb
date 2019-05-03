module VehicleForm
  class RemainingPaymentForm
    include BaseForm

    form_for Vehicle

    attr_accessor :payment_remaining, :payments_remain

    validates :payments_remain, presence: true, unless: :draft?
    validates(
      :payment_remaining,
      currency: { greater_than_or_equal_to: 0, allow_blank: true },
      presence: true,
      if: :payments_remain?
    )

    def payments_remain?
      payments_remain&.to_s == 'true'
    end

    private

    def exclude_from_model
      [:payments_remain]
    end
  end
end
