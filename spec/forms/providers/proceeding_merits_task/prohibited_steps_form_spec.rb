require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ProhibitedStepsForm do
      subject(:prohibited_steps_form) { described_class.new(params) }

      let(:params) do
        {
          uk_removal:,
          details:,
        }
      end
      let(:uk_removal) { "true" }
      let(:details) { nil }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(prohibited_steps_form).to be_valid
          end
        end

        context "when uk_removal is missing" do
          let(:uk_removal) { nil }

          it { expect(prohibited_steps_form).to be_invalid }
        end

        context "when uk_removal is false" do
          let(:uk_removal) { "false" }

          context "and the additional information is missing" do
            it { expect(prohibited_steps_form).to be_invalid }
          end

          context "and the additional information is provided" do
            let(:details) { "some text input" }

            it { expect(prohibited_steps_form).to be_valid }
          end
        end
      end
    end
  end
end
