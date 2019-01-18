require 'rails_helper'

RSpec.describe LegalAidApplications::OutstandingMortgageForm, type: :form do
  let(:legal_aid_application) do
    create :legal_aid_application, outstanding_mortgage_amount: nil
  end
  let(:amount) { Faker::Number.decimal(4) }
  let(:params) do
    {
      model: legal_aid_application,
      outstanding_mortgage_amount: amount
    }
  end
  subject { described_class.new(params) }

  describe '#outstanding_mortgage_amount' do
    let(:existing_amount) { Faker::Number.decimal(4) }
    let(:legal_aid_application) do
      create :legal_aid_application, outstanding_mortgage_amount: existing_amount
    end
    it 'matches the value in params' do
      expect(subject.outstanding_mortgage_amount).to eq(amount)
    end
    context 'when no amount passed in' do
      let(:params) do
        { model: legal_aid_application }
      end
      it 'matches the existing amount' do
        expect(subject.outstanding_mortgage_amount).to eq(existing_amount.to_d)
      end
    end
  end

  describe '#save' do
    it 'does not create a new legal_aid_application' do
      expect { subject.save }.not_to change { LegalAidApplication }
    end

    context 'is called' do
      before do
        subject.save
        legal_aid_application.reload
      end

      it 'updates ammount' do
        expect(legal_aid_application.outstanding_mortgage_amount).to eq(amount.to_d)
      end

      it 'flags outstanding_mortgage' do
        expect(legal_aid_application.outstanding_mortgage?).to be_truthy
      end

      context 'with an empty input' do
        let(:amount) { '' }
        it 'generates an error' do
          expect(subject.errors[:outstanding_mortgage_amount]).to contain_exactly('Enter the outstanding mortgage amount')
        end

        it 'does not update model' do
          expect(legal_aid_application.outstanding_mortgage_amount).to be_nil
          expect(legal_aid_application.outstanding_mortgage?).to be_falsey
        end
      end

      context 'with something not a number' do
        let(:amount) { 'not a number' }
        it 'generates an error' do
          expect(subject.errors[:outstanding_mortgage_amount]).to contain_exactly('Mortgage amount must be an amount of money, like 60,000')
        end

        it 'does not update model' do
          expect(legal_aid_application.outstanding_mortgage_amount).to be_nil
          expect(legal_aid_application.outstanding_mortgage?).to be_falsey
        end
      end

      context 'with negative numbers' do
        let(:amount) { Faker::Number.negative }
        it 'generates an error' do
          expect(subject.errors[:outstanding_mortgage_amount]).to contain_exactly('Mortgage amount must be zero or an amount of money, like 60,000')
        end
      end

      context 'with zero' do
        let(:amount) { 0 }
        it 'does not generates an error' do
          expect(subject.errors[:outstanding_mortgage_amount]).to be_empty
        end
      end

      context 'with comma delimiter' do
        let(:amount) { '12,345' }
        it 'converts it to a number' do
          expect(legal_aid_application.outstanding_mortgage_amount).to eq(12_345)
        end
      end
    end
  end
end
