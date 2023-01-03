require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe NatureOfUrgencyForm do
      subject(:nature_of_urgency_form) { described_class.new(params) }

      let(:params) do
        {
          nature_of_urgency:,
          hearing_date_set:,
          hearing_date_1i:,
          hearing_date_2i:,
          hearing_date_3i:,
        }
      end
      let(:nature_of_urgency) { "Hearing is tomorrow" }
      let(:hearing_date_set) { "true" }
      let(:hearing_date_1i) { Date.tomorrow.year }
      let(:hearing_date_2i) { Date.tomorrow.month }
      let(:hearing_date_3i) { Date.tomorrow.day }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(nature_of_urgency_form).to be_valid
          end
        end

        context "when hearing_date_set is missing" do
          let(:hearing_date_set) { nil }

          it { expect(nature_of_urgency_form).to be_invalid }
        end

        context "when nature_of_urgency is blank" do
          let(:nature_of_urgency) { "" }

          it { expect(nature_of_urgency_form).to be_invalid }
        end

        context "when hearing_date is invalid" do
          let(:hearing_date_3i) { "xx" }

          it { expect(nature_of_urgency_form).to be_invalid }
        end

        context "when hearing_date_set is false" do
          let(:hearing_date_set) { "false" }

          it { expect(nature_of_urgency_form).to be_valid }
        end
      end
    end
  end
end
