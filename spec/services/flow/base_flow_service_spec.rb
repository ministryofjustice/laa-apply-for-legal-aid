require 'rails_helper'

RSpec.describe Flow::BaseFlowService do
  let(:flow_service_class) do
    class TestFlowService < Flow::BaseFlowService; end
    TestFlowService
  end
  let(:steps) do
    Flow::Flows::CitizenStart::STEPS
      .deep_merge(Flow::Flows::CitizenStart::STEPS)
      .deep_merge(Flow::Flows::CitizenEnd::STEPS)
  end
  let(:legal_aid_application) { create :legal_aid_application }
  let(:params) { nil }
  subject(:flow_path) do
    flow_service_class.new(
      legal_aid_application: legal_aid_application,
      current_step: current_step,
      params: params
    )
  end

  before { flow_service_class.use_steps steps }

  describe '#forward_path' do
    let(:current_step) { :information }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    it 'returns forward url' do
      expect(subject.forward_path).to eq('/citizens/consent')
    end

    context 'with logic' do
      let(:current_step) { :information }

      it 'returns forward url' do
        expect(subject.forward_path).to eq('/citizens/consent')
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
  end

  describe '#back_path' do
    let(:current_step) { :information }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    it 'returns back url' do
      expect(subject.back_path).to eq('/citizens/legal_aid_applications')
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
  end

  context 'with basic data' do
    let(:url_helpers) { Rails.application.routes.url_helpers }
    let(:current_step) { :foo }
    let(:path) { :path }
    let(:forward) { :forward }
    let(:back) { :back }
    let(:carry_on_sub_flow) { true }
    let(:check_answers) { :check_answers }
    let(:forward_url) { :forward_url }
    let(:back_url) { :back_url }
    let(:steps) do
      {
        current_step => {
          path: path,
          forward: forward,
          back: back,
          carry_on_sub_flow: carry_on_sub_flow,
          check_answers: check_answers
        },
        forward => {
          path: forward_url
        },
        back => {
          path: back_url
        }
      }
    end

    describe '#current_path' do
      it 'returns path' do
        expect(subject.current_path).to eq(path)
      end

      context 'when path not defined' do
        let(:path) { nil }
        it 'raises an error' do
          expect { subject.current_path }.to raise_error(/not defined/)
        end
      end

      context 'when path is a proc' do
        let(:path) { ->(passed_in) { passed_in } }
        it 'passes in the legal aid application' do
          expect(subject.current_path).to eq(legal_aid_application)
        end

        context 'with params' do
          let(:params) { { foo: :bar } }
          let(:path) { ->(passed_in, params) { [passed_in, params] } }

          it 'passes in the legal aid application and the params' do
            expect(subject.current_path).to eq([legal_aid_application, params])
          end
        end
      end
    end

    describe '#forward_path' do
      subject(:forward_path) { flow_path.forward_path }

      it { is_expected.to eq(forward_url) }

      context 'when the back path is nil' do
        let(:forward_url) { nil }

        it 'raises an error' do
          expect { forward_path }.to raise_error(/not defined/)
        end
      end
    end

    describe '#back_path' do
      subject(:back_path) { flow_path.back_path }

      it 'returns back url' do
        is_expected.to eq(back_url)
      end

      context 'when the back path is nil' do
        let(:back_url) { nil }

        it do
          is_expected.to be nil
        end
      end
    end
  end
end
