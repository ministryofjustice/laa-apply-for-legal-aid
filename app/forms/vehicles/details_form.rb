module Vehicles
  class DetailsForm < BaseForm
    form_for Vehicle

    attr_accessor :estimated_value,
                  :more_than_three_years_old,
                  :payment_remaining,
                  :payments_remain,
                  :used_regularly

    validates :estimated_value,
              currency: { greater_than_or_equal_to: 0, allow_blank: true },
              presence: { unless: :draft? }
    validates :payments_remain, presence: { unless: :draft? }
    validates(
      :payment_remaining,
      currency: { greater_than_or_equal_to: 0, allow_blank: true },
      presence: { unless: :draft? },
      if: :payments_remain?,
    )
    validates :more_than_three_years_old, presence: { unless: :draft? }
    validates :used_regularly, presence: { unless: :draft? }

    def payments_remain?
      payments_remain.to_s == "true"
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
      %i[payment_remaining estimated_value]
    end
  end
end
