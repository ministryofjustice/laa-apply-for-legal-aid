require 'rails_helper'

RSpec.describe Citizens::OutgoingsSummaryController do
  let!(:rent_or_mortgage) { create :transaction_type, :debit, name: 'rent_or_mortgage' }
  let!(:child_care) { create :transaction_type, :debit, name: 'child_care' }
  let!(:maintenance_out) { create :transaction_type, :debit, name: 'maintenance_out' }
  let!(:legal_aid) { create :transaction_type, :debit, name: 'legal_aid' }
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_applicant,
      :with_transaction_period,
      transaction_types: [rent_or_mortgage, child_care]
    )
  end
  let(:secure_id) { legal_aid_application.generate_secure_id }

  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/outgoings_summary' do
    subject { get citizens_outgoings_summary_index_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      subject
      [rent_or_mortgage, child_care].pluck(:name).each do |name|
        legend = I18n.t("transaction_types.names.#{name}")
        expect(parsed_response_body.css("ol li h2#outgoing-type-#{name}").text).to match(/#{legend}/)
      end
    end

    it 'does not display a section for transaction types not linked to this application' do
      subject
      [maintenance_out, legal_aid].pluck(:name).each do |name|
        expect(parsed_response_body.css("ol li h2#outgoing-type-#{name}").size).to eq 0
      end
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional outgoings types section' do
        subject
        expect(response.body).to include(I18n.t('citizens.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end

    context 'all transaction types selected' do
      before do
        legal_aid_application.transaction_types << maintenance_out
        legal_aid_application.transaction_types << legal_aid
        subject
      end
      it 'does not display an Add additional outgoing types section' do
        get citizens_legal_aid_application_path(secure_id)
        expect(response.body).not_to include(I18n.t('citizens.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end

    context 'with assigned (by type) transations' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: child_care, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: [child_care] }

      it 'displays bank transaction' do
        subject
        expect(legal_aid_application.bank_transactions).to include(bank_transaction)
        expect(response.body).to include(bank_transaction.description)
      end
    end
  end
end
