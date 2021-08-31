module VehicleForm
  class UsedRegularlyForm < NewBaseForm

    form_for Vehicle

    attr_accessor :used_regularly

    validates :used_regularly, presence: { unless: :draft? }
  end
end
