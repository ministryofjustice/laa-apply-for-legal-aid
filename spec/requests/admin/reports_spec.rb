require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :request do
  let(:admin_user) { create :admin_user }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_reports_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays report name' do
      subject
      expect(response.body).to include('Download CSV of all submitted applications')
    end

    it 'has a link to the download csv path' do
      subject
      expect(response.body).to include(admin_reports_submitted_csv_path(format: :csv))
    end
  end

  describe 'GET download_submitted' do
    subject { get admin_reports_submitted_csv_path(format: :csv) }

    before do
      create :admin_report, :with_reports_attached
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'sends the data' do
      subject
      expect(response.body).to match(/^col1,col2,col3/)
    end
  end

  describe 'GET download_non_passported' do
    subject { get admin_reports_non_passported_csv_path(format: :csv) }

    before do
      create :admin_report, :with_reports_attached
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'sends the data' do
      subject
      expect(response.body).to match(/^col1,col2,col3/)
    end
  end

  describe 'POST Custom Report' do
    subject { post admin_reports_path, params: params }

    context 'all record types' do
      let(:params) do
        {
          reports_reports_types_creator: {
            application_type: 'A',
            submitted_to_ccms: 'false',
            capital_assessment_result: ['eligible'],
            'records_from(3i)' => '',
            'records_from(2i)' => '',
            'records_from(1i)' => '',
            'records_to(3i)' => '',
            'records_to(2i)' => '',
            'records_to(1i)' => '',
            payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
          }
        }
      end

      it 'calls the report generator' do
        expect(Reports::ReportsTypesCreator).to receive(:call).and_call_original
        subject
      end

      context 'no records found' do
        it 'does not send any csv response data' do
          subject
          expect(response.body).to be_empty
        end
      end

      context 'records found' do
        let(:firm) { create :firm }
        let(:provider) { create :provider, firm: firm }
        let!(:legal_aid_application) do
          create :legal_aid_application,
                 :with_everything,
                 :at_assessment_submitted,
                 provider: provider
        end

        before { subject }

        it 'sends csv response data' do
          expect(response.body).to include('case_ccms_reference,COUNTRY,APPLY_CASE_MEANS_REVIEW')
        end
      end
    end

    context 'validation error' do
      context 'missing application type' do
        let(:params) do
          {
            application_type: '',
            submitted_to_ccms: 'false',
            capital_assessment_result: ['eligible'],
            'records_from(3i)' => '',
            'records_from(2i)' => '',
            'records_from(1i)' => '',
            'records_to(3i)' => '',
            'records_to(2i)' => '',
            'records_to(1i)' => '',
            payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
          }
        end

        it 'returns an error if missing application_type' do
          subject
          expect(response.body).to include('Select if you want to search all cases or a particular type')
        end
      end

      context 'missing submitted to ccms' do
        let(:params) do
          {
            application_type: 'A',
            submitted_to_ccms: '',
            capital_assessment_result: ['eligible'],
            'records_from(3i)' => '',
            'records_from(2i)' => '',
            'records_from(1i)' => '',
            'records_to(3i)' => '',
            'records_to(2i)' => '',
            'records_to(1i)' => '',
            payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
          }
        end

        it 'returns an error if missing submitted_to_ccms' do
          subject
          expect(response.body).to include('Select if you want to search cases submitted to CCMS only')
        end
      end
    end
  end
end
