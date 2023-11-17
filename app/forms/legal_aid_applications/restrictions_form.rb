module LegalAidApplications
  class RestrictionsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_restrictions, :restrictions_details

    before_validation :clear_restrictions_details

    validates :has_restrictions, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?
    validates :restrictions_details, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: proc { has_restrictions.to_s != "true" }

  private

    def clear_restrictions_details
      restrictions_details&.clear if has_restrictions.to_s == "false"
    end
  end
end
