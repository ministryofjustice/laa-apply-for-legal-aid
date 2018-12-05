require 'rails_helper'

RSpec.describe Citizens::OwnHomeForm, type: :form do
  let(:application) { create :legal_aid_application, :with_applicant_and_address }
  let(:attributes) { legal_aid_application.attributes }
  let(:params) { { own_home: 'mortgage' } }
  let(:form_params) { params.merge(model: application) }

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
      expect(@form.errors[:own_home]).to eq [I18n.t('activemodel.errors.models.legal_aid_application.attributes.own_home.blank')]
    end
  end

  describe '#save' do
    let(:attributes) { legal_aid_application.attributes }
    let(:params) { { own_home: 'mortgage' } }
    let(:form_params) { params.merge(model: application) }

    it 'does not create a new applicant' do
      expect { @form.save }.not_to change { LegalAidApplication.count }
    end

    it 'saves updates record with new value of own home attribute' do
      expect(application.own_home).to be_nil
      @form.save
      expect(application.own_home).to eq 'mortgage'
    end

    it 'leaves other attributes on the record unchanged' do
      expected_attributes = application.attributes.symbolize_keys.except(:own_home, :updated_at)
      @form.save
      application.reload
      expected_attributes.each do |attr, val|
        expect(application.send(attr)).to eq(val), "Attr #{attr}: expected #{val}, got #{application.send(attr)}"
      end
    end
  end
end
