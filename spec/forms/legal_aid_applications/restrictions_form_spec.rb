require 'rails_helper'

RSpec.describe LegalAidApplications::RestrictionsForm, type: :form do
  let(:application) { create :legal_aid_application, :with_applicant }
  let(:journey) { %i[providers citizens].sample }
  let(:restrictions_details) { Faker::Lorem.paragraph }
  let(:has_restrictions) { 'true' }
  let(:params) do
    {
      has_restrictions: has_restrictions,
      restrictions_details: restrictions_details,
      journey: journey
    }
  end
  let(:form_params) { params.merge(model: application) }

  subject { described_class.new(form_params) }

  describe '#save' do
    before do
      subject.save
      application.reload
    end

    it 'updates applications' do
      expect(application.restrictions_details).to eq restrictions_details
    end

    it 'updates applications has restriction' do
      expect(application.has_restrictions).to eq true
    end

    context 'has no restrictions' do
      let(:has_restrictions) { 'false' }
      let(:restrictions_details) { '' }

      it 'saves false into has restrictions' do
        expect(application.has_restrictions).to eq false
      end

      it 'does not add restrictions details' do
        expect(application.restrictions_details).to be_empty
      end
    end

    context 'params invalid' do
      let(:has_restrictions) { 'true' }
      let(:restrictions_details) { '' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(subject.errors[:restrictions_details]).to include I18n.t("activemodel.errors.models.legal_aid_application.attributes.restrictions_details.#{journey}.blank")
      end

      context 'no restrictions present' do
        let(:has_restrictions) { '' }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'generates the expected error message' do
          expect(subject.errors[:has_restrictions]).to include I18n.t("activemodel.errors.models.legal_aid_application.attributes.has_restrictions.#{journey}.blank")
        end
      end
    end

    describe '#save_as_draft' do
      before do
        subject.save_as_draft
        application.reload
      end

      it 'updates the legal_aid_application restrictions information' do
        expect(application.has_restrictions).to eq true
        expect(application.restrictions_details).to_not be_empty
      end
    end
  end
end
