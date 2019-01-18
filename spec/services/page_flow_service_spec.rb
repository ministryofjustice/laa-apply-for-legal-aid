require 'rails_helper'

RSpec.describe PageFlowService do
  let(:legal_aid_application) { create :legal_aid_application }
  subject { described_class.new(legal_aid_application, current_step) }

  describe '#back_path' do
    let(:current_step) { :property_values }
    let(:expected_back_path) { :citizens_own_home_path }
    let(:expected_error) { "Back step of #{current_step} is not defined" }

    it 'returns back path' do
      expect(subject.back_path).to eq(expected_back_path)
    end

    context 'with logic' do
      let(:current_step) { :shared_ownerships }
      let(:expected_back_path) { :citizens_property_value_path }

      it 'returns back path' do
        expect(subject.back_path).to eq(expected_back_path)
      end
    end

    context 'step is not defined' do
      let(:current_step) { :foo_bar }

      it 'raises an error' do
        expect { subject.back_path }.to raise_error(expected_error)
      end
    end

    context 'back step is not defined' do
      let(:current_step) { :own_homes }
      before { stub_const("#{described_class}::STEPS_FLOW", own_homes: {}) }

      it 'raises an error' do
        expect { subject.back_path }.to raise_error(expected_error)
      end
    end
  end

  describe '#forward_path' do
    let(:current_step) { :percentage_homes }
    let(:expected_forward_path) { :citizens_savings_and_investment_path }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    it 'returns forward path' do
      expect(subject.forward_path).to eq(expected_forward_path)
    end

    context 'with logic' do
      let(:current_step) { :own_homes }
      let(:expected_forward_path) { :citizens_property_value_path }

      it 'returns forward path' do
        expect(subject.forward_path).to eq(expected_forward_path)
      end
    end

    context 'step is not defined' do
      let(:current_step) { :foo_bar }

      it 'raises an error' do
        expect { subject.forward_path }.to raise_error(expected_error)
      end
    end

    context 'forward step is not defined' do
      let(:current_step) { :own_homes }
      before { stub_const("#{described_class}::STEPS_FLOW", own_homes: {}) }

      it 'raises an error' do
        expect { subject.forward_path }.to raise_error(expected_error)
      end
    end
  end
end
