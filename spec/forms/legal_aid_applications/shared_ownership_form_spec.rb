require 'rails_helper'

RSpec.describe LegalAidApplications::SharedOwnershipForm, type: :form do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant_and_address }
  let(:attributes) { legal_aid_application.attributes }
  let(:params) { { shared_ownership: 'No' } }
  let(:form_params) { params.merge(model: legal_aid_application) }

  before(:each) do
    @form = described_class.new(form_params)
  end

  describe '.model_name' do
    it 'should be "LegalAidApplication"' do
      expect(described_class.model_name).to eq('LegalAidApplication')
    end
  end

  describe 'validations' do
    let(:params) { {} }

    it 'errors if own_home not specified' do
      expect(@form.save).to be false
      expect(@form.errors[:shared_ownership]).to eq [I18n.t('activemodel.errors.models.legal_aid_application.attributes.shared_ownership.blank')]
    end
  end

  describe '#save' do
    let(:attributes) { legal_aid_application.attributes }
    let(:params) { { shared_ownership: 'no' } }
    let(:form_params) { params.merge(model: legal_aid_application) }

    it 'does not create a new legal aid application ' do
      expect { @form.save }.not_to change { LegalAidApplication.count }
    end

    it 'saves updates record with new value of own home attribute' do
      expect(legal_aid_application.shared_ownership).to be_nil
      @form.save
      expect(legal_aid_application.shared_ownership).to eq 'no'
    end

    it 'leaves other attributes on the record unchanged' do
      expected_attributes = legal_aid_application.attributes.symbolize_keys.except(:state, :shared_ownership, :updated_at, :created_at)
      @form.save
      legal_aid_application.reload
      expected_attributes.each do |attr, val|
        expect(legal_aid_application.send(attr)).to eq(val), "Attr #{attr}: expected #{val}, got #{legal_aid_application.send(attr)}"
      end
    end
  end
end
