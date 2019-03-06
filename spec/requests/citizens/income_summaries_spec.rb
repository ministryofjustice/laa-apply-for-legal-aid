require 'rails_helper'

RSpec.describe Citizens::IncomeSummaryController do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }

  before do
    @salary = create :transaction_type, name: 'salary', operation: 'credit'
    @benefits = create :transaction_type, name: 'benefits', operation: 'credit'
    @maintenance = create :transaction_type, name: 'maintenance_in', operation: 'credit'
    @pension = create :transaction_type, name: 'pension', operation: 'credit'

    legal_aid_application.transaction_types = [@salary, @benefits]
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/income_summary' do
    before { get citizens_income_summary_index_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      %w[salary benefits].each do |name|
        legend = I18n.t("transaction_types.names.#{name}")
        expect(parsed_response_body.css("ol li h2#income-type-#{name}").text).to match(/#{legend}/)
      end
    end

    it 'does not display a section for transaction types not linked to this application' do
      %w[maintenance pension].each do |name|
        expect(parsed_response_body.css("ol li h2#income-type-#{name}").size).to eq 0
      end
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional income types section' do
        expect(response.body).to include(I18n.t('citizens.income_summary.add_other_income.add_other_income'))
      end
    end

    context 'all transaction types selected' do
      before do
        legal_aid_application.transaction_types << @maintenance
        legal_aid_application.transaction_types << @pension
      end
      it 'does not display an Add additional income types section' do
        get citizens_legal_aid_application_path(secure_id)
        expect(response.body).not_to include(I18n.t('citizens.income_summaries.add_other_income.add_other_income'))
      end
    end
  end

  def parsed_response_body
    Nokogiri::HTML(response.body)
  end
end
