require 'rails_helper'

RSpec.describe Applicants::BasicDetailsForm, type: :form do
  describe '.model_name' do
    it 'should be "Applicant"' do
      expect(described_class.model_name).to eq('Applicant')
    end
  end

  let(:attributes) { attributes_for :applicant }

  let(:params) { attributes.slice :first_name, :last_name }
  subject { described_class.new(params) }

  describe '#model' do
    it 'returns a new applicant' do
      expect(subject.model).to be_a(Applicant)
      expect(subject.model).not_to be_persisted
    end
  end

  describe 'attributes' do
    it 'matches passed in attributes' do
      expect(subject.first_name).to be_present
      expect(subject.first_name).to eq(attributes[:first_name])
      expect(subject.last_name).to eq(attributes[:last_name])
    end
  end

end
