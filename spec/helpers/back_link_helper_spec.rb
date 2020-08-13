require 'rails_helper'

RSpec.describe BackLinkHelper, type: :helper do
  let(:application) { create :legal_aid_application }

  describe '#check_answer_url_for' do
    context 'citizen' do
      it 'returns the path' do
        url = back_link_url_for(:citizens, :information, application)
        expect(url).to eq '/citizens/legal_aid_applications'
      end

      # context 'when params are provided' do
      #   let(:params) { { transaction_type: 'benefits' } }
      #   it 'returns the correct path' do
      #     url = check_answer_url_for(:providers, :incoming_transactions, application, params)
      #     expect(url).to eq "/providers/applications/#{application.id}/incoming_transactions/benefits"
      #   end
      # end
    end
  end
end
