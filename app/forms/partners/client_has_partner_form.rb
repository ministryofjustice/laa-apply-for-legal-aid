module Partners
  class ClientHasPartnerForm < BaseForm
    form_for Applicant

    attr_accessor :has_partner

    validates :has_partner, inclusion: [true, false, "true", "false"], unless: :draft?

    def has_partner?
      has_partner.eql?("true")
    end
  end
end
