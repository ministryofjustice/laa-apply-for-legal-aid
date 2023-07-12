module Partners
  class ContraryInterestsForm < BaseForm
    form_for Applicant

    attr_accessor :partner_has_contrary_interest

    validates :partner_has_contrary_interest, inclusion: %w[true false], unless: :draft?

    def partner_has_contrary_interest?
      partner_has_contrary_interest.eql?("true")
    end
  end
end
