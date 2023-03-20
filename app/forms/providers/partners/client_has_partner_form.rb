module Providers
  module Partners
    class ClientHasPartnerForm < BaseForm
      form_for Applicant

      attr_accessor :has_partner

      validates :has_partner, inclusion: %w[true false], unless: :draft?
    end
  end
end
