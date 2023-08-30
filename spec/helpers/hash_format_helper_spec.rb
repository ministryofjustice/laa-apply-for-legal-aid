require "rails_helper"

RSpec.describe HashFormatHelper do
  let(:source) { { key: "value", sub_hash: { sub_key: "sub_value" }, array_hash: [{ array_one: "array_value" }, { array_two: "array_value" }] } }
  let(:expected_response) do
    '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Key</dt><dd>Value</dd></dl>' \
      '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Sub Hash</dt>' \
      '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Sub Key</dt><dd>Sub_value</dd></dl></dl>' \
      '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Array Hash</dt>' \
      '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Array One</dt><dd>Array_value</dd></dl>' \
      '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Array Two</dt><dd>Array_value</dd></dl></dl>'
  end

  describe "#format_hash" do
    subject(:helper_format_hash) { format_hash(source) }

    context "when passed a hash" do
      it { is_expected.to eql expected_response }
    end

    context "when hash has key but no value" do
      let(:source) { { result: nil } }

      it "returns empty string" do
        expect(helper_format_hash).to eq ""
      end
    end

    context "when passed an array of GUIDs" do
      let(:source) do
        { multiple_employments: %w[159de866-8a9e-44cf-86b4-a3ed01da0533 cb2dd4ff-6f61-4ef6-82c3-b4e02b1ac42a] }
      end

      let(:expected_response) do
        '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Multiple Employments</dt>' \
          "<dd>159de866-8a9e-44cf-86b4-a3ed01da0533</dd>" \
          "<dd>cb2dd4ff-6f61-4ef6-82c3-b4e02b1ac42a</dd></dl>"
      end

      it { is_expected.to eql expected_response }
    end

    context "when passed invalid data" do
      before do
        allow(Rails.logger).to receive(:info).at_least(:once)
        helper_format_hash
      end

      let(:source) { { key: :ten } }
      let(:expected_response) { "Unexpected value type of 'Symbol' for key 'Key' in format_hash: :ten" }

      it "logs error messages" do
        expect(Rails.logger).to have_received(:info).with(expected_response).once
      end
    end
  end
end
