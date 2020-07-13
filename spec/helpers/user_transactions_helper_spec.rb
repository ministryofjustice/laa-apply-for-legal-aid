require 'rails_helper'

RSpec.describe UserTransactionsHelper, type: :helper do
  let(:transaction_type) { create :transaction_type, :salary }
  let(:legal_aid_application) do
    create :legal_aid_application, :with_applicant, transaction_types: [transaction_type]
  end
  let(:locale_namespace) { '' }

  before do
    allow(helper).to(
      receive(:yes_no).with(boolean).and_return(true)
    )
  end

  describe '#incomings_list' do
    subject { helper.incomings_list(legal_aid_application.transaction_types.credits, locale_namespace: locale_namespace) }

    context 'for citizen' do
      let(:locale_namespace) { 'transaction_types.names.citizens' }

      it 'returns correct hash' do
        expect(subject[:items].first.to_h).to match hash_result
      end

      context 'with excluded state benefit' do
        let(:transaction_type) { create :transaction_type, :excluded_benefits }
        it 'returns correct hash' do
          expect(subject[:items]).to be_empty
        end
      end
      context 'no transactions' do
        let(:legal_aid_application) { create :legal_aid_application }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end

  describe '#payments_list' do
    let(:transaction_type) { create :transaction_type, :maintenance_out }
    subject { helper.payments_list(legal_aid_application.transaction_types.debits, locale_namespace: locale_namespace) }

    context 'for citizen' do
      let(:locale_namespace) { 'transaction_types.names.citizens' }

      it 'returns correct hash' do
        expect(subject[:items].first.to_h).to match hash_result
      end

      context 'no transactions' do
        let(:legal_aid_application) { create :legal_aid_application }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end

  def hash_result
    {
      label: I18n.t("#{locale_namespace}.#{transaction_type.name}"),
      name: transaction_type.name,
      amount_text: true
    }
  end
end
