module Providers
  module ApplicationMeritsTask
    class PLFCourtOrderForm < BaseForm
      form_for LegalAidApplication

      attr_accessor :plf_court_order

      validates :plf_court_order, inclusion: %w[true false], unless: :draft?

      def copy_of_court_order?
        plf_court_order == "true"
      end
    end
  end
end
