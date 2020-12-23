require 'rails_helper'

class TestFlowService < Flow::BaseFlowService; end

RSpec.describe Flow::BaseFlowService do
  let(:flow_service_class) do
    TestFlowService
  end
  let(:steps) do
    Flow::Flows::CitizenStart::STEPS
      .deep_merge(Flow::Flows::CitizenCapital::STEPS)
      .deep_merge(Flow::Flows::CitizenEnd::STEPS)
  end
  let(:legal_aid_application) { create :legal_aid_application }
  let(:params) { nil }
  subject do
    flow_service_class.new(
      legal_aid_application: legal_aid_application,
      current_step: current_step,
      params: params
    )
  end

  before { flow_service_class.use_steps steps }

  describe '#forward_path' do
    let(:current_step) { :accounts }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    context 'default locale' do
      it 'returns forward url with en locale' do
        expect(subject.forward_path).to eq('/citizens/additional_accounts?locale=en')
      end
    end

    context 'Welsh locale' do
      around do |example|
        I18n.locale = :cy
        example.run
        I18n.locale = I18n.default_locale
      end
      it 'returns forward url with cy locale' do
        expect(subject.forward_path).to eq('/citizens/additional_accounts?locale=cy')
      end
    end

    context 'with logic' do
      let(:current_step) { :consents }

      it 'returns forward url' do
        expect(subject.forward_path).to eq('/citizens/contact_provider?locale=en')
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

  context 'with basic data' do
    let(:url_helpers) { Rails.application.routes.url_helpers }
    let(:current_step) { :foo }
    let(:path) { :path }
    let(:forward) { :forward }
    let(:carry_on_sub_flow) { true }
    let(:check_answers) { :check_answers }
    let(:forward_url) { :forward_url }
    let(:steps) do
      {
        current_step => {
          path: path,
          forward: forward,
          carry_on_sub_flow: carry_on_sub_flow,
          check_answers: check_answers
        },
        forward => {
          path: forward_url
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

      context 'path for step is not defined' do
        let(:path) { nil }

        it 'raises an error' do
          expect { subject.current_path }.to raise_error(/not defined/)
        end
      end
    end

    describe '#forward_path' do
      it 'returns forward url' do
        expect(subject.forward_path).to eq(forward_url)
      end
    end
  end
end
