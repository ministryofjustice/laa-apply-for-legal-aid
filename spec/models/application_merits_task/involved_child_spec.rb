require 'rails_helper'

module ApplicationMeritsTask
  RSpec.describe InvolvedChild do
    let(:involved_child) { build :involved_child, full_name: full_name }

    subject { involved_child.split_full_name }

    describe '#split_full_name' do
      context 'first name and last name' do
        let(:full_name) { 'John Smith' }
        it 'separates out first and last name' do
          expect(subject).to eq %w[John Smith]
        end
      end

      context 'with  multiple embedded spaces' do
        let(:full_name) { 'Michael      Winner' }
        it 'separates out first and last name' do
          expect(subject).to eq %w[Michael Winner]
        end
      end

      context 'first name, middle name, last name' do
        let(:full_name) { 'Philip   Stephen    Richards' }
        it 'separates out first and last name' do
          expect(subject).to eq ['Philip Stephen', 'Richards']
        end
      end

      context 'just last name' do
        let(:full_name) { 'Prince' }
        it 'returns unspecified as first name' do
          expect(subject).to eq %w[unspecified Prince]
        end
      end

      context 'double-barrelled names' do
        let(:full_name) { 'Jacob Rees-Mogg' }
        it 'is not phased by the hyphen' do
          expect(subject).to eq %w[Jacob Rees-Mogg]
        end
      end

      context 'irish names' do
        let(:full_name) { "Daira O'Brien" }
        it 'is not phased by the apostrophe' do
          expect(subject).to eq ['Daira', "O'Brien"]
        end
      end
    end
  end
end
