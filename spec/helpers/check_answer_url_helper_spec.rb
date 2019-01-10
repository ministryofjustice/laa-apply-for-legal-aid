require 'rails_helper'

RSpec.describe CheckAnswerUrlHelper, type: :helper do
  let(:application) { build :legal_aid_application, id: 'bf07c530-718a-4537-b9e1-c04ad956cc71' }

  describe '#check_answer_url_for' do
    context 'provider' do
      it 'returns the correct path' do
        url = check_answer_url_for(:provider, :outstanding_mortgage, application)
        expect(url).to eq '/providers/applications/bf07c530-718a-4537-b9e1-c04ad956cc71/outstanding_mortgage#outstanding_mortgage_amount'
      end
    end

    context 'citizen' do
      it 'returns the correct path' do
        url = check_answer_url_for(:citizen, :property_value)
        expect(url).to eq '/citizens/property_value#property_value'
      end
    end

    context 'error raising' do
      context 'invalid user type' do
        it 'raises' do
          expect {
            check_answer_url_for(:employee, :own_home)
          }.to raise_error ArgumentError, 'Wrong user type passed to #check_answer_url_for'
        end
      end

      context 'provider' do
        context 'invalid field name' do
          it 'raises' do
            expect {
              check_answer_url_for(:provider, :holiday_let, application)
            }.to raise_error ArgumentError, 'Invalid field name for #check_answer_url_for: holiday_let'
          end
        end
      end

      context 'citizen' do
        context 'invalid field name' do
          it 'raises' do
            expect {
              check_answer_url_for(:citizen, :granny_flat)
            }.to raise_error ArgumentError, 'Invalid field name for #check_answer_url_for: granny_flat'
          end
        end
      end
    end
  end
end
