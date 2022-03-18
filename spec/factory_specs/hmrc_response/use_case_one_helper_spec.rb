require "rails_helper"

module FactoryHelpers
  module HMRCResponse
    RSpec.describe UseCaseOne do
      let(:correlation_id) { SecureRandom.uuid }

      it "returns a hash with expected keys" do
        response = described_class.new(correlation_id).response
        expect(response["submission"]).to eq correlation_id
        expect(response["status"]).to eq "completed"
        expect(response["data"].size).to eq 19
      end

      it "can be used inside a factory" do
        rec = create :hmrc_response, :use_case_one
        expect(rec.response["status"]).to eq "completed"
        expect(rec.response["data"].size).to eq 19
      end
    end
  end
end
