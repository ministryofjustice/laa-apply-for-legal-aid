require 'rails_helper'
require Rails.root.join('lib/tasks/helpers/ccms_payload_yamlizer')

RSpec.describe CcmsPayloadYamlizer do
  let(:parser) { described_class.new(filename) }
  let(:filename) { '/Users/stephenrichards/moj/apply/ccms_integration/example_payloads/multi_proc/MP_1333536_NP_multi children.xml' }

  it 'parses' do
    expect($stdout).to receive(:puts).at_least(1) # suppress output to console
    parser.run
  end

  describe '#calculate_new_key' do
    let(:hash) do
      {
        'key_a' => 'aa',
        'key_b' => 'bb',
        'key_b[1]' => 'bb1',
        'key_b[2]' => 'bb1'
      }
    end

    context 'key does not exist in the hash' do
      it 'returns the same value' do
        expect(parser.__send__(:calculate_new_key, hash, 'keyz')).to eq 'keyz'
      end
    end

    context 'key_without_square_brackets is in the hash' do
      it 'returns the key suffixed by [1]' do
        expect(parser.__send__(:calculate_new_key, hash, 'key_a')).to eq 'key_a[1]'
      end
    end

    context 'several keys exist' do
      it 'returns the next key in sequence' do
        expect(parser.__send__(:calculate_new_key, hash, 'key_b')).to eq 'key_b[3]'
      end
    end
  end
end
