require 'rails_helper'

RSpec.describe AgeCalculator do
  let(:date) { Date.parse('15-08-2010') }
  subject { AgeCalculator.call(date_of_birth, date) }

  context 'birthday is just before date' do
    let(:date_of_birth) { Date.parse('14-08-2000') }
    it('gives the right age') { expect(subject).to eq(10) }
  end

  context 'birthday is just after date' do
    let(:date_of_birth) { Date.parse('16-08-2000') }
    it('gives the right age') { expect(subject).to eq(9) }
  end

  context 'birthday is same day as date' do
    let(:date_of_birth) { Date.parse('16-08-2000') }
    it('gives the right age') { expect(subject).to eq(9) }
  end

  context 'date_of_birth is on 29th of february and date is not a leap year' do
    let(:date_of_birth) { Date.parse('29-02-2000') }
    it('gives the right age') { expect(subject).to eq(10) }
  end
end
