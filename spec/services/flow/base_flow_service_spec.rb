require "rails_helper"

class TestFlowService < Flow::BaseFlowService; end

RSpec.describe Flow::BaseFlowService do
  subject(:base_flow_service) do
    flow_service_class.new(
      legal_aid_application:,
      current_step:,
      params:,
    )
  end

  let(:flow_service_class) do
    TestFlowService
  end
  let(:steps) do
    Flow::Flows::CitizenStart::STEPS
      .deep_merge(Flow::Flows::CitizenEnd::STEPS)
  end
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:params) { nil }

  before { flow_service_class.use_steps steps }

  describe "#forward_path" do
    let(:current_step) { :accounts }
    let(:expected_error) { "Forward step of #{current_step} is not defined" }

    context "when on the default locale" do
      it "returns forward url with en locale" do
        expect(base_flow_service.forward_path).to eq("/citizens/additional_accounts?locale=en")
      end
    end

    context "when using the Welsh locale" do
      around do |example|
        I18n.with_locale(:cy) { example.run }
      end

      it "returns forward url with cy locale" do
        expect(base_flow_service.forward_path).to eq("/citizens/additional_accounts?locale=cy")
      end
    end

    context "and logic exists" do
      let(:current_step) { :consents }

      it "returns forward url" do
        expect(base_flow_service.forward_path).to eq("/citizens/contact_provider?locale=en")
      end
    end

    context "when a step is not defined" do
      let(:current_step) { :foo_bar }

      it "raises an error" do
        expect { base_flow_service.forward_path }.to raise_error(/not defined/)
      end
    end

    context "when the forward step is not defined" do
      let(:steps) { { foo: :bar } }

      it "raises an error" do
        expect { base_flow_service.forward_path }.to raise_error(/not defined/)
      end
    end
  end

  context "when there is basic data" do
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
          path:,
          forward:,
          carry_on_sub_flow:,
          check_answers:,
        },
        forward => {
          path: forward_url,
        },
      }
    end

    describe "#current_path" do
      it "returns path" do
        expect(base_flow_service.current_path).to eq(path)
      end

      context "when path is a proc" do
        let(:path) { ->(passed_in) { passed_in } }

        it "passes in the legal aid application" do
          expect(base_flow_service.current_path).to eq(legal_aid_application)
        end

        context "and params exist" do
          let(:params) { { foo: :bar } }
          let(:path) { ->(passed_in, params) { [passed_in, params] } }

          it "passes in the legal aid application and the params" do
            expect(base_flow_service.current_path).to eq([legal_aid_application, params])
          end
        end
      end

      context "when the path for step is not defined" do
        let(:path) { nil }

        it "raises an error" do
          expect { base_flow_service.current_path }.to raise_error(/not defined/)
        end
      end
    end

    describe "#forward_path" do
      it "returns forward url" do
        expect(base_flow_service.forward_path).to eq(forward_url)
      end
    end
  end
end
