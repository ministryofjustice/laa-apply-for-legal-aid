require 'rails_helper'

RSpec.describe ProvidersHelper, type: :helper do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_everything,
           :means_completed
  end

  describe '#url_for_application' do
    context 'means assessment completed' do
      it 'should return client_received_legal_help path' do
        expect(url_for_application(legal_aid_application)).to include 'client_received_legal_help'
      end
    end

    context 'means assessment not complete' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_everything,
               :provider_submitted
      end

      it 'should return current path' do
        legal_aid_application.update!(provider_step: :applicants)
        expect(url_for_application(legal_aid_application)).to include 'applicant'
      end

      it 'should return proceedings type if no path given' do
        legal_aid_application.update!(provider_step: '')
        expect(url_for_application(legal_aid_application)).to include 'proceedings_types'
      end
    end
  end
end
