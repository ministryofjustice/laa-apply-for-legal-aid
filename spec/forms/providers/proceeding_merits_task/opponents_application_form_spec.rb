require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe OpponentsApplicationForm do
      subject(:opponents_application_form) { described_class.new(params) }

      let(:params) do
        {
          has_opponents_application:,
          reason_for_applying:,
        }
      end
      let(:has_opponents_application) { "true" }
      let(:reason_for_applying) { nil }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(opponents_application_form).to be_valid
          end
        end

        context "when has_opponents_application is missing" do
          let(:has_opponents_application) { nil }

          it { expect(opponents_application_form).not_to be_valid }
        end

        context "when has_opponents_application is false" do
          let(:has_opponents_application) { "false" }

          context "and the additional information is missing" do
            it { expect(opponents_application_form).not_to be_valid }
          end

          context "and the additional information is provided" do
            let(:reason_for_applying) { "some text input" }

            it { expect(opponents_application_form).to be_valid }
          end
        end
      end
    end
  end
end
