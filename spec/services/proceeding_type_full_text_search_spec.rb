require 'rails_helper'

RSpec.describe ProceedingTypeFullTextSearch do
  before(:all) do
    ServiceLevel.create!(service_level_number: 3, name: 'Full representation')
    ProceedingType.populate
  end

  after(:all) do
    ServiceLevel.delete_all
    ProceedingType.delete_all
  end

  describe '.call' do
    subject { described_class.call(search_term) }

    context 'searching for a non-existent term' do
      let(:search_term) { 'animals' }

      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end

    context 'searching for a term that only exists on one record' do
      let(:search_term) { 'mutilation' }

      it 'returns one result row' do
        result_set = subject
        expect(result_set.size).to eq 1
      end

      it 'returns an instance of Result' do
        result = subject.first
        expect(result).to be_an_instance_of(ProceedingTypeFullTextSearch::Result)
      end

      it 'returns FGM Protection order' do
        result = subject.first
        expect(result.meaning).to eq 'FGM Protection Order'
        expect(result.description).to eq 'To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.'
      end
    end

    context 'searching for a term which occures in more than one proceeding' do
      let(:search_term) { 'molestation' }

      it 'returns two results' do
        result_set = subject
        expect(result_set.size).to eq 2
      end

      it 'returns the one with the search ter in additional search terms first' do
        result_set = subject
        expect(result_set.map(&:meaning)).to eq ['Harassment - injunction', 'Non-molestation order']
      end
    end

    context 'multiple term searches' do
      let(:search_term) { 'protection order' }

      it 'only returns results matching both terms' do
        result_set = subject
        expect(result_set.map(&:meaning)).to eq ['Forced marriage protection order',
                                                 'FGM Protection Order',
                                                 'Variation or discharge under section 5 protection from harassment act 1997']
      end
    end
  end
end
