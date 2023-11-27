module Vehicles
  class DetailsForm < BaseForm
    RadioOption = Struct.new(:value, :label)

    SINGLE_VALUE_ATTRIBUTES = %i[
      client
      partner
      client_and_partner
    ].freeze

    form_for Vehicle

    attr_accessor :owner,
                  :estimated_value,
                  :more_than_three_years_old,
                  :payment_remaining,
                  :payments_remain,
                  :used_regularly

    validates :owner, presence: { if: :has_partner? }
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
    alias_method :save!, :save

    def self.radio_options
      translation_root = "providers.means.vehicle_details.show.owner.options"
      SINGLE_VALUE_ATTRIBUTES.map { |option| RadioOption.new(option, I18n.t("#{translation_root}.#{option}")) }
    end

  private

    def exclude_from_model
      [:payments_remain]
    end

    def attributes_to_clean
      %i[payment_remaining estimated_value]
    end

    def has_partner?
      model.legal_aid_application.applicant.has_partner_with_no_contrary_interest?
    end
  end
end
