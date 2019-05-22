require 'rails_helper'

RSpec.describe YamlStore do
  let(:file_path) { ccms_data_file_path 'simple_thresholds.yml' }
  let(:data) { YAML.load_file file_path }

  describe '#threshold' do
    let(:threshold) { Faker::Number.number(4) }
    let(:data) { { foo: threshold } }
    let(:threshold_store) { described_class.new(data) }

    it 'returns threshold' do
      expect(threshold_store.threshold(:foo)).to eq(threshold)
    end

    it 'raises error if unknown' do
      expect { threshold_store.threshold(:unkonwn) }.to raise_error(described_class::KeyNotRecognisedError)
    end

    context 'with string keyed data' do
      let(:data) { { 'foo' => threshold } }

      it 'returns threshold' do
        expect(threshold_store.threshold(:foo)).to eq(threshold)
      end
    end
  end

  describe '.from_yaml_file' do
    let(:threshold_store) { described_class.from_yaml_file(file_path) }

    it 'returns data from file' do
      expect(threshold_store.threshold(:ccms)).to eq(data['ccms'].deep_symbolize_keys)
    end

    context 'using sub-section' do
      let(:threshold_store) { described_class.from_yaml_file(file_path, section: :ccms) }

      it 'returns data from sub-section of file' do
        expect(threshold_store.threshold(:capital_upper)).to eq(data['ccms']['capital_upper'])
      end
    end
  end

  describe '.threshold' do
    let(:data) { YAML.load_file file_path }
    let(:subclass) { Class.new(described_class) }
    let(:configure_subclass) { subclass.use_yml_file(file_path) }

    before { configure_subclass }

    it 'returns data from file' do
      expect(subclass.threshold(:ccms)).to eq(data['ccms'].deep_symbolize_keys)
    end

    context 'with subsection defined' do
      let(:configure_subclass) { subclass.use_yml_file(file_path, section: :ccms) }

      it 'returns data from sub-section of file' do
        expect(subclass.threshold(:capital_upper)).to eq(data['ccms']['capital_upper'])
      end
    end
  end
end
