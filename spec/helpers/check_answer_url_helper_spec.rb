require 'rails_helper'

RSpec.describe CheckAnswerUrlHelper, type: :helper do
  let(:application) { create :legal_aid_application }

  describe '#check_answer_url_for' do
    context 'provider' do
      it 'returns the path' do
        url = check_answer_url_for(:providers, :own_homes, application)
        expect(url).to eq "/providers/applications/#{application.id}/own_home"
      end

      it 'returns the path with anchor' do
        url = check_answer_url_for(:providers, :property_values, application)
        expect(url).to eq "/providers/applications/#{application.id}/property_value#property_value"
      end
    end

    context 'citizen' do
      it 'returns the path' do
        url = check_answer_url_for(:citizens, :identify_types_of_outgoings)
        expect(url).to eq '/citizens/identify_types_of_outgoing'
      end

      it 'returns the path with anchor' do
        url = check_answer_url_for(:citizens, :property_values)
        expect(url).to eq '/citizens/property_value#property_value'
      end
    end
  end
end
