require 'rails_helper'

module CCMS
  RSpec.describe ApplicantSearchResponseParser do
    describe 'parsing applicant search responses' do
      let(:no_results_response_xml) { File.read("#{File.dirname(__FILE__)}/data/applicant_search_response_no_results.xml") }
      let(:one_result_response_xml) { File.read("#{File.dirname(__FILE__)}/data/applicant_search_response_one_result.xml") }
      let(:multiple_results_response_xml) { File.read("#{File.dirname(__FILE__)}/data/applicant_search_response_multiple_results.xml") }

      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser = described_class.new('20190301030405987654', no_results_response_xml)
          parser.parse
        }.to raise_error RuntimeError, 'Invalid transaction request id'
      end

      context 'there are no applicants returned' do
        let(:parser) { described_class.new('20190301030405123456', no_results_response_xml) }

        before { parser.parse }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '0'
        end

        it 'does not return an applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to be_nil
        end
      end

      context 'there is one applicant returned' do
        let(:parser) { described_class.new('20190301030405123456', one_result_response_xml) }

        before { parser.parse }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '1'
        end

        it 'returns the applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to eq '4390016'
        end
      end

      context 'there are multiple applicants returned' do
        let(:parser) { described_class.new('20190301030405123456', multiple_results_response_xml) }

        before { parser.parse }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '2'
        end

        it 'returns the first applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to eq '4390017'
        end
      end
    end
  end
end
