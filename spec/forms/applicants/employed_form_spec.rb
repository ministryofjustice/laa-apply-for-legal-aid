require 'rails_helper'

RSpec.describe Applicants::EmployedForm, type: :form do
  let!(:application) { create :legal_aid_application, applicant: applicant }
  let(:applicant) { create :applicant }

  let(:params) { { employed: true } }
  let(:form_params) { params.merge(model: applicant) }

  subject { described_class.new(form_params) }

  describe 'validations' do
    let(:params) { {} }

    it 'errors if employed not specified' do
      expect(subject.save).to be false
      expect(subject.errors[:employed]).to eq [I18n.t('activemodel.errors.models.applicant.attributes.employed.blank')]
    end
  end

  describe '#save' do
    let(:params) { { employed: 'false' } }
    let(:form_params) { params.merge(model: applicant) }

    it 'updates record with new value of employed attribute' do
      expect(applicant.employed).to be_nil
      subject.save
      expect(applicant.employed).to eq false
    end
  end
end
