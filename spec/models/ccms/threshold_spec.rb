require 'rails_helper'

module CCMS
  RSpec.describe Threshold do
    let(:data) { YAML.load_file Rails.root.join('config/ccms/thresholds.yml') }

    describe '.threshold' do
      it 'returns data from yaml file' do
        expect(described_class.threshold(:capital_upper)).to eq(data['ccms']['capital_upper'])
      end
    end
  end
end
