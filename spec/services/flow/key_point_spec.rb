require "rails_helper"

RSpec.describe Flow::KeyPoint do
  subject(:flow_key_point) { described_class.new(journey, key_point) }

  let(:journey) { :providers }
  let(:key_point) { :start_after_applicant_completes_means }
  let(:step) { :client_completed_means }
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:flow) do
    Flow::BaseFlowService.flow_service_for(
      journey,
      legal_aid_application:,
      current_step: step,
    )
  end

  describe "#step" do
    it "returns the matching step" do
      expect(flow_key_point.step).to eq(step)
    end
  end

  describe "#path" do
    it "returns the matching path from flow" do
      expect(flow_key_point.path(legal_aid_application)).to eq(flow.current_path)
    end
  end

  describe ".step_for" do
    it "returns the matching step" do
      response = described_class.step_for(
        journey:,
        key_point:,
      )
      expect(response).to eq(step)
    end
  end

  describe ".path_for" do
    it "returns the matching path" do
      response = described_class.path_for(
        journey:,
        key_point:,
        legal_aid_application:,
      )
      expect(response).to eq(flow.current_path)
    end
  end
end
