require 'rails_helper'

module CFE
  RSpec.describe ObtainStateBenefitTypesService do
    let(:service) { described_class.new(nil) }

    around do |example|
      VCR.turn_off!
      example.run
      VCR.turn_on!
    end

    describe '.call' do
      context 'successful response' do
        before do
          stub_request(:get, service.cfe_url)
            .to_return(status: 200, body: expected_json_response)
        end

        it 'returns a hash representation of the json response' do
          expect(described_class.call).to eq expected_response
        end
      end

      context 'unsuccessful response' do
        before do
          stub_request(:get, service.cfe_url)
            .to_return(status: 501, body: nil)
        end

        it 'raises' do
          expect { described_class.call }.to raise_error CFE::SubmissionError, 'Unable to get State Benefit Types from CFE Server. Status 501'
        end
      end

      def expected_json_response
        expected_response.to_json
      end

      def expected_response
        [
          {
            'label' => 'budget_advances',
            'name' => 'Budget Advances',
            'dwp_code' => nil
          },
          {
            'label' => 'care_in_the_community_direct_payment',
            'name' => 'Care in the Community Direct Payment',
            'dwp_code' => nil
          },
          {
            'label' => 'earnings_top_up',
            'name' => 'Earnings Top Up',
            'dwp_code' => nil
          }
        ].to_json
      end
    end
  end
end
