module CFE
  RSpec.shared_examples 'a failed call to CFE' do |service, url|
    context 'http status 422' do
      # let(:faraday_response) { double Faraday::Response, status: 422, body: error_response }
      before do
        expect_any_instance_of(described_class).to receive(:request_body).exactly(2).times.and_return(expected_payload)
        stub_request(:post, "localhost:3001/assessments/#{submission.assessment_id}/applicant")
          .with(body: expected_payload)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an exception' do
        expect {
          service.call(submission)
        }.to raise_error CFE::SubmissionError, 'Unprocessable entity'
      end

      it 'updates the submission record from initialised to failed' do
        expect(submission.submission_histories).to be_empty
        expect { service.call(submission) }.to raise_error CFE::SubmissionError

        expect(submission.submission_histories.count).to eq 1
        history = submission.submission_histories.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq expected_url(submission, url)
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 422
        expect(history.response_payload).to eq error_response
        expect(history.error_message).to be_nil
      end
    end

    context 'other failing http status' do
      before do
        expect_any_instance_of(described_class).to receive(:request_body).exactly(2).times.and_return(expected_payload)
        stub_request(:post, "localhost:3001/assessments/#{submission.assessment_id}/applicant")
          .with(body: expected_payload)
          .to_return(body: '', status: 503)
      end

      it 'raises an exception' do
        expect {
          service.call(submission)
        }.to raise_error CFE::SubmissionError, 'Unsuccessful HTTP response code'
      end

      it 'updates the submission record from initialised to failed' do
        expect(submission.submission_histories).to be_empty
        expect { service.call(submission) }.to raise_error CFE::SubmissionError

        expect(submission.submission_histories.count).to eq 1
        history = submission.submission_histories.last
        expect(history.http_response_status).to eq 503
        expect(history.response_payload).to eq ''
        expect(history.error_message).to be_nil
      end
    end

    def error_response
      {
        errors: ['Detailed error message'],
        success: false
      }.to_json
    end

    def expected_url(submission, url)
      if /^http/.match?(url)
        url
      else
        "#{ENV['CHECK_FINANCIAL_ELIGIBILITY_URL']}/assessments/#{submission.assessment_id}/#{url}"
      end
    end
  end
end
