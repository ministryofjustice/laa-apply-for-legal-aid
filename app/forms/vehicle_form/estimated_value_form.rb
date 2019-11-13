module VehicleForm
  class EstimatedValueForm
    include BaseForm

    form_for Vehicle

    attr_accessor :estimated_value

    validates :estimated_value,
              currency: { greater_than_or_equal_to: 0, allow_blank: true },
              presence: { unless: :draft? }

    def attributes_to_clean
      [:estimated_value]
    end
  end
end
