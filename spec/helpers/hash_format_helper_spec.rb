require 'rails_helper'

RSpec.describe HashFormatHelper, type: :helper do
  let(:source) { { key: 'value', sub_hash: { sub_key: 'sub_value' } } }
  let(:expected_response) do
    '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Key</dt><dd>Value</dd></dl>' \
    '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Sub Hash</dt>'\
    '<dl class="govuk-body kvp govuk-!-margin-bottom-0"><dt>Sub Key</dt><dd>Sub_value</dd></dl></dl>'
  end

  describe '#format_hash' do
    subject { format_hash(source) }

    context 'when passed a hash' do
      it { is_expected.to eql expected_response }
    end

    context 'hash has key but no value' do
      let(:source) { { result: nil } }
      it 'returns empty string' do
        expect(subject).to eq ''
      end
    end

    context 'when passed invalid data' do
      before do
        allow(Rails.logger).to receive(:info).at_least(:once)
        subject
      end

      let(:source) { { key: ['value', 'value 2'] } }
      let(:expected_response) { "Unexpected value type of 'Array' for key 'Key' in format_hash: [\"value\", \"value 2\"]" }

      it 'logs error messages' do
        expect(Rails.logger).to have_received(:info).with(expected_response).once
      end
    end
  end
end
