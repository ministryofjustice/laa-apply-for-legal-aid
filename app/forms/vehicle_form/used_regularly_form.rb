module VehicleForm
  class UsedRegularlyForm
    include BaseForm

    form_for Vehicle

    attr_accessor :used_regularly

    validates :used_regularly, presence: { unless: :draft? }
  end
end
