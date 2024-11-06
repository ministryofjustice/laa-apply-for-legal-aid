module Providers
  module Partners
    class ReceivesStateBenefitsForm < BaseForm
      form_for Partner

      attr_accessor :receives_state_benefits

      validates :receives_state_benefits, presence: true, unless: :draft?

      def receives_state_benefits?
        receives_state_benefits.eql?("true")
      end
    end
  end
end
