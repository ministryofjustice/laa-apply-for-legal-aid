module DisregardsHandling
  extend ActiveSupport::Concern

  included do
    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_no_disregard_and_another_checkbox_not_both_checked, unless: :draft?

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

  private

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def none_and_another_checkbox_checked?
      checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
    end
  end
end
