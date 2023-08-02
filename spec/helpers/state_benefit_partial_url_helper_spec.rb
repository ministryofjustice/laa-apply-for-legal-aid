require "rails_helper"

RSpec.describe StateBenefitPartialUrlHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:transaction) { create(:regular_transaction, legal_aid_application:) }

  describe ".state_benefit_partial_url" do
    subject(:helper_method) { state_benefit_partial_url(:fake, "means", legal_aid_application, transaction) }

    it "raises an error when called with unexpected values" do
      expect { helper_method }.to raise_error "type fake not supported"
    end
  end
end
