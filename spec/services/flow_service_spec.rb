require 'rails_helper'

RSpec.describe Flow::BaseFlowService do
  let(:flow_service_class) do
    class TestFlowService < Flow::BaseFlowService; end
    TestFlowService
  end
  let(:steps) { Flow::Flows::CitizenStart::STEPS.deep_merge(Flow::Flows::CitizenCapital::STEPS) }
  let(:legal_aid_application) { create :legal_aid_application }
  subject do
    flow_service_class.new(
      legal_aid_application: legal_aid_application,
      current_step: current_step
    )
  end

  before { flow_service_class.use_steps steps }

  describe '#back_path' do
    let(:current_step) { :property_values }

    it 'returns back url' do
      expect(subject.back_path).to eq('/citizens/own_home')
    end

    context 'with logic' do
      let(:current_step) { :shared_ownerships }

      it 'returns back url' do
        expect(subject.back_path).to eq('/citizens/property_value')
      end
    end

    context 'step is not defined' do
      let(:current_step) { :foo_bar }

      it 'raises an error' do
        expect { subject.back_path }.to raise_error(/not defined/)
      end
    end

    context 'back step is not defined' do
      let(:steps) { { foo: :bar } }

      it 'raises an error' do
        expect { subject.back_path }.to raise_error(/not defined/)
      end
    end

    context 'checking answer' do
      let(:legal_aid_application) { create :legal_aid_application, :checking_answers }

      context 'and check_answers page is defined' do
        it 'returns check_answers url' do
          expect(subject.back_path).to eq('/citizens/check_answers')
        end
      end

      context 'and check_answers page is not defined' do
        let(:current_step) { :consents }

        it 'returns back url' do
          expect(subject.back_path).to eq('/citizens/information')
        end
      end
    end
  end

  describe '#forward_path' do
    let(:current_step) { :percentage_homes }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    it 'returns forward url' do
      expect(subject.forward_path).to eq('/citizens/savings_and_investment')
    end

    context 'with logic' do
      let(:current_step) { :own_homes }

      it 'returns forward url' do
        expect(subject.forward_path).to eq('/citizens/property_value')
      end
    end

    context 'step is not defined' do
      let(:current_step) { :foo_bar }

      it 'raises an error' do
        expect { subject.forward_path }.to raise_error(/not defined/)
      end
    end

    context 'forward step is not defined' do
      let(:steps) { { foo: :bar } }

      it 'raises an error' do
        expect { subject.forward_path }.to raise_error(/not defined/)
      end
    end

    context 'checking answer' do
      let(:legal_aid_application) { create :legal_aid_application, :checking_answers }

      context 'and check_answers page is defined' do
        let(:current_step) { :savings_and_investments }

        it 'returns check_answers url' do
          expect(subject.forward_path).to eq('/citizens/check_answers')
        end

        context 'and we are in a sub flow' do
          let(:legal_aid_application) { create :legal_aid_application, :checking_answers, :with_own_home_mortgaged }
          let(:current_step) { :own_homes }

          it 'returns next page in the sub flow' do
            expect(subject.forward_path).to eq('/citizens/property_value')
          end
        end
      end

      context 'and check_answers page is not defined' do
        let(:current_step) { :information }

        it 'returns forward url' do
          expect(subject.forward_path).to eq('/citizens/consent')
        end
      end
    end
  end
end
