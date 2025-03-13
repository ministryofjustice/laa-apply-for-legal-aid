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
      let(:details) { "" }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(prohibited_steps_form).to be_valid
          end
        end

        context "when uk_removal is missing" do
          let(:uk_removal) { "" }

          it { expect(prohibited_steps_form).not_to be_valid }
        end

        context "when uk_removal is false" do
          let(:uk_removal) { "false" }

          context "and fields are missing", :aggregate_failures do
            it "is invalid" do
              expect(prohibited_steps_form).not_to be_valid
              expect(prohibited_steps_form.errors).to be_added(:details, :blank)
            end
          end

          context "and required fields are provided" do
            let(:details) { "some text input" }

            it { expect(prohibited_steps_form).to be_valid }
          end
        end
      end
    end
  end
end
