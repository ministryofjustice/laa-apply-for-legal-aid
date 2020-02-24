module CFE
  RSpec.shared_examples 'a failed call to CFE' do
    # shared examples for testing failure conditions when posting to Check Financial Eligibility Service
    #
    context 'http status 422' do
      before do
        stub_request(:post, service.cfe_url)
          .with(body: service.request_body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an exception' do
        expect {
          described_class.call(submission)
        }.to raise_error CFE::SubmissionError, /Unprocessable entity/
      end

      it 'updates the submission history record from initialised to failed' do
        expect(submission.submission_histories).to be_empty
        expect { described_class.call(submission) }.to raise_error CFE::SubmissionError

        expect(submission.submission_histories.count).to eq 1
        history = submission.submission_histories.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq service.cfe_url
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq service.request_body
        expect(history.http_response_status).to eq 422
        expect(history.response_payload).to eq error_response
        expect(history.error_message).to eq 'Unexpected response: 422'
      end
    end

    context 'other failing http status' do
      before do
        stub_request(:post, service.cfe_url)
          .with(body: service.request_body)
          .to_return(body: '', status: 503)
      end

      it 'raises an exception' do
        expect {
          described_class.call(submission)
        }.to raise_error CFE::SubmissionError, 'Unsuccessful HTTP response code'
      end

      it 'updates the submission record from initialised to failed' do
        expect(submission.submission_histories).to be_empty
        expect { described_class.call(submission) }.to raise_error CFE::SubmissionError

        expect(submission.submission_histories.count).to eq 1
        history = submission.submission_histories.last
        expect(history.http_response_status).to eq 503
        expect(history.response_payload).to eq ''
        expect(history.error_message).to eq 'Unexpected response: 503'
      end
    end

    context 'connection error' do
      it 'creates a CFE::Submission error and writes a history record with a backtrace' do
        stub_request(:post, service.cfe_url).to_raise(Faraday::ConnectionFailed.new('my faraday connection failed'))
        expect {
          described_class.call(submission)
        }.to raise_error CFE::SubmissionError
        history = CFE::SubmissionHistory.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq service.cfe_url
        expect(history.http_method).to eq 'POST'
        expect(history.http_response_status).to be_nil
        expect(history.response_payload).to be_nil
        expect(history.error_message).to eq "#{described_class} received Faraday::ConnectionFailed: my faraday connection failed"
        expect(history.error_backtrace).not_to be_nil
      end
    end

    def error_response
      {
        errors: ['Detailed error message'],
        success: false
      }.to_json
    end
  end
end
