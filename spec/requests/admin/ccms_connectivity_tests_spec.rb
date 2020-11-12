require 'rails_helper'

RSpec.describe Admin::CCMSConnectivityTestsController, type: :request do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list :legal_aid_application, count, :with_applicant }
  let(:admin_user) { create :admin_user }

  before { sign_in admin_user }

  describe 'GET /admin/ccms_connectivity_tests/:id' do
    let(:response_stub) do
      <<~XML
        <?xml version='1.0' encoding='UTF-8'?>
        <note>
          <body>response stub</body>
        </note>
      XML
    end

    subject { get admin_ccms_connectivity_test_path(legal_aid_applications.first.id) }

    before do
      allow(CCMS::Requestors::ReferenceDataRequestor).to receive(:new).and_return(
        instance_double(CCMS::Requestors::ReferenceDataRequestor, call: response_stub)
      )
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('response stub')
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
