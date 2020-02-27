require 'rails_helper'

RSpec.describe CleanupCapitalAttributes do
  describe '#sync' do
    let(:legal_aid_application) { create :legal_aid_application, :with_everything, test_condition }
    let(:cleanup_capital_attributes) { described_class.new(legal_aid_application) }
    before do
      cleanup_capital_attributes.call
      legal_aid_application.reload
    end
    context 'on own home set to no' do
      let(:test_condition) { :without_own_home }

      it 'resets property values' do
        expect(legal_aid_application.property_value).to be_blank
      end
      it 'resets outstanding mortgage' do
        expect(legal_aid_application.outstanding_mortgage_amount).to be_blank
      end
      it 'resets shared ownership' do
        expect(legal_aid_application.shared_ownership).to be_blank
      end
      it 'resets percentage home' do
        expect(legal_aid_application.percentage_home).to be_blank
      end
    end

    context 'on shared ownership set to no' do
      let(:test_condition) { :with_home_sole_owner }

      it 'does not reset property values' do
        expect(legal_aid_application.property_value).not_to be_blank
      end
      it 'does not reset outstanding mortgage' do
        expect(legal_aid_application.outstanding_mortgage_amount).not_to be_blank
      end
      it 'does not reset shared ownership' do
        expect(legal_aid_application.shared_ownership).not_to be_blank
      end
      it 'resets percentage home' do
        expect(legal_aid_application.percentage_home).to be_blank
      end
    end

    context 'on own home set to own outright' do
      let(:test_condition) { :with_own_home_owned_outright }

      it 'does not reset property values' do
        expect(legal_aid_application.property_value).not_to be_blank
      end
      it 'resets outstanding mortgage' do
        expect(legal_aid_application.reload.outstanding_mortgage_amount).to be_blank
      end
      it 'does not reset shared ownership' do
        expect(legal_aid_application.shared_ownership).not_to be_blank
      end
      it 'does not percentage home' do
        expect(legal_aid_application.percentage_home).not_to be_blank
      end
    end
  end
end
