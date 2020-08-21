require 'rails_helper'

RSpec.describe CheckAnswerUrlHelper, type: :helper do
  let(:application) { create :legal_aid_application }

  describe '#check_answer_url_for' do
    context 'provider' do
      it 'returns the path' do
        url = check_answer_url_for(:providers, :own_homes, application)
        expect(url).to eq "/providers/applications/#{application.id}/own_home"
      end

      context 'when params are provided' do
        let(:params) { { transaction_type: 'benefits' } }
        it 'returns the correct path' do
          url = check_answer_url_for(:providers, :incoming_transactions, application, params)
          expect(url).to eq "/providers/applications/#{application.id}/incoming_transactions/benefits"
        end
      end

      it 'returns the path with anchor' do
        url = check_answer_url_for(:providers, :property_values, application)
        expect(url).to eq "/providers/applications/#{application.id}/property_value#property_value"
      end
    end

    context 'citizen' do
      it 'returns the path' do
        url = check_answer_url_for(:citizens, :consents)
        expect(url).to eq '/citizens/consent'
      end
    end
  end
end
