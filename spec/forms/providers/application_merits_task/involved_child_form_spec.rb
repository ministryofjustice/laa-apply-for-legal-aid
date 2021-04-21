require 'rails_helper'

module Providers
  module ApplicationMeritsTask
    RSpec.describe InvolvedChildForm do
      let(:earliest_date) { Date.new(2000, 1, 1) }
      let(:dob) { Faker::Date.between(from: earliest_date, to: Date.current) }
      let(:full_name) { Faker::Name.name }
      let(:params) do
        {
          full_name: full_name,
          date_of_birth_3i: dob.day.to_s,
          date_of_birth_2i: dob.month.to_s,
          date_of_birth_1i: dob.year.to_s
        }
      end

      subject { described_class.new(params) }

      describe '#valid?' do
        context 'all fields valid' do
          it 'returns true' do
            expect(subject).to be_valid
          end
        end

        context 'missing name' do
          let(:full_name) { '' }
          it 'returns false' do
            expect(subject).not_to be_valid
            expect(subject.errors[:full_name]).to eq ["can't be blank"]
          end
        end

        context 'date in the future' do
          let(:dob) { Date.tomorrow }
          it 'returns false' do
            expect(subject).not_to be_valid
            expect(subject.errors[:date_of_birth]).to eq ['Date of birth cannot be in the future']
          end
        end

        context 'missing date of birth' do
          let(:params) do
            {
              full_name: full_name,
              date_of_birth_3i: '',
              date_of_birth_2i: '',
              date_of_birth_1i: ''
            }
          end
          it 'returns false' do
            expect(subject).not_to be_valid
            expect(subject.errors[:date_of_birth]).to eq ["can't be blank"]
          end
        end
      end
    end
  end
end
