require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientDenialOfAllegationForm do
      subject(:denial_form) { described_class.new(params) }

      let(:params) do
        {
          denies_all:,
          additional_information:,
        }
      end
      let(:denies_all) { true }
      let(:additional_information) { nil }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(denial_form).to be_valid
          end
        end

        context "when denies_all is missing" do
          let(:denies_all) { nil }

          it { expect(denial_form).not_to be_valid }
        end

        context "when denies_all is false" do
          let(:denies_all) { false }

          context "and the additional information is missing" do
            it { expect(denial_form).not_to be_valid }
          end

          context "and the additional information is provided" do
            let(:additional_information) { "some text input" }

            it { expect(denial_form).to be_valid }
          end
        end
      end
    end
  end
end
