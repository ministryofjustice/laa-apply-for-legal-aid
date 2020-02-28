module VehicleForm
  class AgeForm
    include BaseForm

    form_for Vehicle

    attr_accessor :more_than_three_years_old

    validates :more_than_three_years_old, presence: { unless: :draft? }
  end
end
