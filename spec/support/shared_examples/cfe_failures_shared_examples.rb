module CFE
  RSpec.shared_examples 'a failed call to CFE' do
    # shared examples for testing failure conditions when posting to Check Financial Eligibility Service
    #
    # expects the following variables to have been defined in the calling scope:
    # * cfe_url - the full url (host and path) that is being posted to
    # * expected_payload - the JSON payload posted to the CFE endpoint
    #
    context 'http status 422' do
      before do
        stub_request(:post, cfe_url)
          .with(body: expected_payload)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an exception' do
        expect {
          described_class.call(submission)
        }.to raise_error CFE::SubmissionError, 'Unprocessable entity'
      end

      it 'updates the submission record from initialised to failed' do
        expect(submission.submission_histories).to be_empty
        expect { described_class.call(submission) }.to raise_error CFE::SubmissionError

        expect(submission.submission_histories.count).to eq 1
        history = submission.submission_histories.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq cfe_url
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 422
        expect(history.response_payload).to eq error_response
        expect(history.error_message).to be_nil
      end
    end

    context 'other failing http status' do
      before do
        stub_request(:post, cfe_url)
          .with(body: expected_payload)
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
        expect(history.error_message).to be_nil
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
