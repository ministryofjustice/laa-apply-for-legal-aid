require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientOfferedUndertakingsForm do
      subject(:undertaking_form) { described_class.new(form_params) }

      let(:params) do
        {
          offered:,
          additional_information_true:,
          additional_information_false:,
        }
      end
      let(:offered) { "true" }
      let(:additional_information_true) { nil }
      let(:additional_information_false) { nil }
      let(:undertaking) { create(:undertaking) }
      let(:form_params) { params.merge(model: undertaking) }

      describe "#valid?" do
        context "when offered is missing" do
          let(:offered) { nil }

          it { expect(undertaking_form).not_to be_valid }
        end

        context "when offered is true" do
          context "and the additional information is missing" do
            it { expect(undertaking_form).not_to be_valid }
          end

          context "and the additional information is provided" do
            let(:additional_information_true) { "some text input" }

            it { expect(undertaking_form).to be_valid }
          end
        end

        context "when offered is false" do
          let(:offered) { "false" }

          context "and the additional information is missing" do
            it { expect(undertaking_form).not_to be_valid }
          end

          context "and the additional information is provided" do
            let(:additional_information_false) { "some text input" }

            it { expect(undertaking_form).to be_valid }
          end
        end
      end

      describe "#save" do
        subject(:save_form) { undertaking_form.save }

        before { save_form }

        context "when both additional information fields are populated" do
          let(:additional_information_true) { "Yes Answer" }
          let(:additional_information_false) { "No Answer" }

          context "and the user answered 'yes'" do
            it { expect(undertaking.reload.additional_information).to eq additional_information_true }
          end

          context "and the user answered 'no'" do
            let(:offered) { "false" }

            it { expect(undertaking.reload.additional_information).to eq additional_information_false }
          end
        end
      end
    end
  end
end
