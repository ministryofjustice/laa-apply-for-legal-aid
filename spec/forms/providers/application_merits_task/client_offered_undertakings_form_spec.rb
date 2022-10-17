require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientOfferedUndertakingsForm do
      subject(:undertaking_form) { described_class.new(params) }

      let(:params) do
        {
          offered:,
          additional_information:,
        }
      end
      let(:offered) { true }
      let(:additional_information) { nil }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(undertaking_form).to be_valid
          end
        end

        context "when offered is missing" do
          let(:offered) { nil }

          it { expect(undertaking_form).to be_invalid }
        end

        context "when offered is false" do
          let(:offered) { false }

          context "and the additional information is missing" do
            it { expect(undertaking_form).to be_invalid }
          end

          context "and the additional information is provided" do
            let(:additional_information) { "some text input" }

            it { expect(undertaking_form).to be_valid }
          end
        end
      end
    end
  end
end
