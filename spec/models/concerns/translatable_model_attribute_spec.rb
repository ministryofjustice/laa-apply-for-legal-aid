require 'rails_helper'

RSpec.describe TranslatableModelAttribute do
  let(:record) { create :legal_aid_application }

  describe '#enum_t' do
    context 'translation exists' do
      it 'translates' do
        expect(record.state).to eq 'initiated'
        expect(record.enum_t(:state)).to eq 'In progress'
      end
    end

    context 'translation does not exist' do
      it 'returns translation not found message' do
        allow(record).to receive(:state).and_return('unknown_state')
        expect(record.enum_t(:state)).to eq 'translation missing: en.model_enum_translations.legal_aid_application.state.unknown_state'
      end
    end
  end

  describe '.enum_ts' do
    let(:klass) { Feedback }
    let(:satisfactions) { klass.satisfactions }
    let(:instance) { klass.new }
    subject { klass.enum_ts(:satisfaction) }

    it 'returns a hash with an entry for each state' do
      expect(subject.keys).to match_array satisfactions.keys.map(&:to_sym)
    end

    it 'has values that match the translations' do
      key = subject.keys.sample
      instance.satisfaction = key
      expect(subject[key]).to eq(instance.enum_t(:satisfaction))
    end
  end
end
