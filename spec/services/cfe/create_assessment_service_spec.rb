require 'rails_helper'

module CFE
  RSpec.describe CreateAssessmentService do

    before(:all) do
      VCR.configure { |c| c.ignore_hosts 'localhost' }
    end

    let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
    let(:faraday_connection) { double Faraday }
    let(:expected_payload) do
      {
        'client_reference_id': 'L-XYZ-999',
        'submission_date': Date.today. strftime('%Y-%m-%d'),
        'matter_proceeding_type': 'domestic_abuse'
      }.to_json
    end
    let(:expected_response) do

    end

    describe 'successful post' do
      it 'calls with expected params and payload' do
        allow(application).to receive(:calculation_date).and_return(Date.today)
        connection_param = double.as_null_object
        expect(Faraday).to receive(:new).with(url: 'http://localhost:3001').and_return(faraday_connection)
        expect(faraday_connection).to receive(:post).and_yield(connection_param)
        expect(connection_param).to receive(:url).with('/assessments')
        expect(connection_param).to receive(:headers)
        expect(connection_param).to receive(:body=).with(expected_payload)

        CreateAssessmentService.call(application)
      end
    end
  end
end
