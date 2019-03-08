require 'rails_helper'

RSpec.describe Citizens::OutgoingsSummaryController do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  let!(:rent_or_mortgage) { create :transaction_type, name: 'rent_or_mortgage', operation: 'debit' }
  let!(:council_tax) { create :transaction_type, name: 'council_tax', operation: 'debit' }
  let!(:child_care) { create :transaction_type, name: 'child_care', operation: 'debit' }
  let!(:maintenance_out) { create :transaction_type, name: 'maintenance_out', operation: 'debit' }
  let!(:legal_aid) { create :transaction_type, name: 'legal_aid', operation: 'debit' }

  before do
    legal_aid_application.transaction_types = [rent_or_mortgage, council_tax]
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/outgoings_summary' do
    before { get citizens_outgoings_summary_index_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      [rent_or_mortgage, council_tax].pluck(:name).each do |name|
        legend = I18n.t("transaction_types.names.#{name}")
        expect(parsed_response_body.css("ol li h2#outgoing-type-#{name}").text).to match(/#{legend}/)
      end
    end

    it 'does not display a section for transaction types not linked to this application' do
      [child_care, maintenance_out, legal_aid].pluck(:name) do |name|
        expect(parsed_response_body.css("ol li h2#outgoing-type-#{name}").size).to eq 0
      end
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional outgoings types section' do
        expect(response.body).to include(I18n.t('citizens.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end

    context 'all transaction types selected' do
      before do
        legal_aid_application.transaction_types << child_care
        legal_aid_application.transaction_types << maintenance_out
        legal_aid_application.transaction_types << legal_aid
      end
      it 'does not display an Add additional outgoing types section' do
        get citizens_legal_aid_application_path(secure_id)
        expect(response.body).not_to include(I18n.t('citizens.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end
  end
end
