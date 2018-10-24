require 'rails_helper'
# rubocop:disable Lint/AmbiguousBlockAssociation
RSpec.describe Applicants::BasicDetailsForm, type: :form do
  describe '.model_name' do
    it 'should be "Applicant"' do
      expect(described_class.model_name).to eq('Applicant')
    end
  end

  let(:attributes) { attributes_for :applicant }
  let(:legal_aid_application) { create :legal_aid_application }

  let(:attr_list) do
    %i[
      first_name last_name national_insurance_number
      date_of_birth
    ]
  end

  let(:params) do
    {
      applicant:  attributes.slice(*attr_list),
      legal_aid_application_id: legal_aid_application.id
    }
  end
  subject { described_class.new(params) }

  describe '#save' do
    let(:applicant) { Applicant.last }
    it 'creates a new applicant' do
      expect { subject.save }.to change { Applicant.count }
    end

    it 'saves attributes to the new applicant' do
      subject.save
      attr_list.each do |attribute|
        expect(applicant.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end

    it 'saved application belongs to legal_aid_application' do
      subject.save
      expect(applicant).to eq(legal_aid_application.reload.applicant)
    end

    context 'with first name missing' do
      before { attr_list.delete(:first_name) }
      it 'does not persist model' do
        expect { subject.save }.not_to change { Applicant.count }
      end

      it 'errors to be present' do
        subject.save
        expect(subject.errors[:first_name]).to be_present
      end
    end

    context 'with an invalid NINO' do
      before { attributes[:national_insurance_number] = 'foobar' }
      it 'does not persist model' do
        expect { subject.save }.not_to change { Applicant.count }
      end

      it 'errors to be present' do
        subject.save
        expect(subject.errors[:national_insurance_number]).to be_present
      end
    end

    context 'with an invalid dob' do
      before { attributes[:date_of_birth] = 3.days.from_now }
      it 'does not persist model' do
        expect { subject.save }.not_to change { Applicant.count }
      end

      it 'errors to be present' do
        subject.save
        expect(subject.errors[:date_of_birth]).to be_present
      end
    end

    context 'with dob elements' do
      let(:params) do
        {
          applicant: {
            first_name: attributes[:first_name],
            last_name: attributes[:last_name],
            national_insurance_number: attributes[:national_insurance_number],
            dob_year: attributes[:date_of_birth].year.to_s,
            dob_month: attributes[:date_of_birth].month.to_s,
            dob_day: attributes[:date_of_birth].day.to_s
          },
          legal_aid_application_id: legal_aid_application.id
        }
      end

      it 'is valid' do
        expect { subject.save }.to change { Applicant.count }
      end

      it 'saves the date' do
        subject.save
        expect(Applicant.last.date_of_birth).to eq(attributes[:date_of_birth])
      end
    end

    context 'with invalid dob elements' do
      let(:params) do
        {
          applicant: {
            first_name: attributes[:first_name],
            last_name: attributes[:last_name],
            national_insurance_number: attributes[:national_insurance_number],
            dob_year: '10',
            dob_month: '21',
            dob_day: '44'
          },
          legal_aid_application_id: legal_aid_application.id
        }
      end

      it 'is not valid' do
        expect { subject.save }.not_to change { Applicant.count }
      end

      it 'sets errors' do
        subject.save
        expect(subject.errors[:date_of_birth]).to be_present
      end
    end
  end

  describe '#model' do
    it 'returns a new applicant' do
      expect(subject.model).to be_a(Applicant)
      expect(subject.model).not_to be_persisted
    end
  end

  describe 'attributes' do
    it 'matches passed in attributes' do
      expect(subject.first_name).to be_present
      attr_list.each do |attribute|
        expect(subject.send(attribute)).to eq(attributes[attribute]), "Should match #{attribute}"
      end
    end
  end

  describe '#legal_aid_application' do
    it 'returns the passed in item' do
      expect(subject.legal_aid_application).to eq(legal_aid_application)
    end
  end
end
# rubocop:enable Lint/AmbiguousBlockAssociation
