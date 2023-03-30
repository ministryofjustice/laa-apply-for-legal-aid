require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ProhibitedStepsForm do
      subject(:prohibited_steps_form) { described_class.new(params) }

      let(:params) do
        {
          uk_removal:,
          details:,
          confirmed_not_change_of_name:,
        }
      end

      let(:uk_removal) { "true" }
      let(:details) { "" }
      let(:confirmed_not_change_of_name) { "" }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(prohibited_steps_form).to be_valid
          end
        end

        context "when uk_removal is missing" do
          let(:uk_removal) { "" }

          it { expect(prohibited_steps_form).to be_invalid }
        end

        context "when uk_removal is false" do
          let(:uk_removal) { "false" }

          context "and fields are missing", :aggregate_failures do
            it "is invalid" do
              expect(prohibited_steps_form).to be_invalid
              expect(prohibited_steps_form.errors).to be_added(:details, :blank)
              expect(prohibited_steps_form.errors).to be_added(
                :confirmed_not_change_of_name,
                :inclusion,
                value: "",
              )
            end
          end

          context "and required fields are provided" do
            let(:details) { "some text input" }
            let(:confirmed_not_change_of_name) { "true" }

            it { expect(prohibited_steps_form).to be_valid }
          end
        end
      end
    end
  end
end
