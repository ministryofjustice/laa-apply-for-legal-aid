require 'rails_helper'

RSpec.describe Respondents::RespondentForm, type: :form do
  let(:respondent) { create :respondent }
  let(:sample_respondent) { build :respondent }
  let(:i18n_scope) { 'activemodel.errors.models.respondent.attributes' }
  let(:custom_params) { {} }
  let(:sample_params) { sample_respondent.attributes.except('id', 'legal_aid_application_id', 'created_at', 'updated_at').transform_values(&:to_s) }

  subject { described_class.new(sample_params.merge(custom_params).merge(model: respondent)) }

  describe '#save' do
    before do
      subject.save
      respondent.reload
    end

    it 'updates the respondent' do
      expect(respondent.understands_terms_of_court_order).to eq(sample_respondent.understands_terms_of_court_order)
      expect(respondent.understands_terms_of_court_order_details).to eq(sample_respondent.understands_terms_of_court_order_details)
      expect(respondent.warning_letter_sent).to eq(sample_respondent.warning_letter_sent)
      expect(respondent.warning_letter_sent_details).to eq(sample_respondent.warning_letter_sent_details)
      expect(respondent.police_notified).to eq(sample_respondent.police_notified)
      expect(respondent.police_notified_details).to eq(sample_respondent.police_notified_details)
      expect(respondent.bail_conditions_set).to eq(sample_respondent.bail_conditions_set)
      expect(respondent.bail_conditions_set_details).to eq(sample_respondent.bail_conditions_set_details)
    end

    context "details are empty but they don't have to be entered" do
      let(:custom_params) do
        {
          understands_terms_of_court_order: 'true',
          warning_letter_sent: 'true',
          understands_terms_of_court_order_details: '',
          warning_letter_sent_details: ''
        }
      end

      it 'updates the respondent' do
        expect(respondent.understands_terms_of_court_order).to eq(true)
        expect(respondent.warning_letter_sent).to eq(true)
        expect(respondent.understands_terms_of_court_order_details).to eq('')
        expect(respondent.warning_letter_sent_details).to eq('')
      end
    end

    context 'radio button are empty' do
      let(:custom_params) do
        {
          understands_terms_of_court_order: '',
          warning_letter_sent: '',
          police_notified: '',
          bail_conditions_set: ''
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates errors' do
        expect(subject.errors[:understands_terms_of_court_order].join).to eq(I18n.t('understands_terms_of_court_order.blank', scope: i18n_scope))
        expect(subject.errors[:warning_letter_sent].join).to eq(I18n.t('warning_letter_sent.blank', scope: i18n_scope))
        expect(subject.errors[:police_notified].join).to eq(I18n.t('police_notified.blank', scope: i18n_scope))
        expect(subject.errors[:bail_conditions_set].join).to eq(I18n.t('bail_conditions_set.blank', scope: i18n_scope))
      end

      it 'generates errors in the right order' do
        expect(subject.errors.attribute_names).to eq(
          %i[
            understands_terms_of_court_order
            warning_letter_sent
            police_notified
            bail_conditions_set
          ]
        )
      end
    end

    context 'details are empty even though they should be present' do
      let(:custom_params) do
        {
          understands_terms_of_court_order: 'false',
          warning_letter_sent: 'false',
          police_notified: %w[true false].sample,
          bail_conditions_set: 'true',
          understands_terms_of_court_order_details: '',
          warning_letter_sent_details: '',
          police_notified_details: '',
          bail_conditions_set_details: ''
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates errors' do
        expect(subject.errors[:understands_terms_of_court_order_details].join).to eq(I18n.t('understands_terms_of_court_order_details.blank', scope: i18n_scope))
        expect(subject.errors[:warning_letter_sent_details].join).to eq(I18n.t('warning_letter_sent_details.blank', scope: i18n_scope))
        expect(subject.errors[:police_notified_details].join).to eq(I18n.t('police_notified_details.blank', scope: i18n_scope))
        expect(subject.errors[:bail_conditions_set_details].join).to eq(I18n.t('bail_conditions_set_details.blank', scope: i18n_scope))
      end

      it 'generates errors in the right order' do
        expect(subject.errors.attribute_names).to eq(
          %i[
            understands_terms_of_court_order_details
            warning_letter_sent_details
            police_notified_details
            bail_conditions_set_details
          ]
        )
      end
    end
  end

  describe '#save_as_draft' do
    before do
      subject.save_as_draft
      respondent.reload
    end

    it 'updates the respondent' do
      expect(respondent.understands_terms_of_court_order).to eq(sample_respondent.understands_terms_of_court_order)
      expect(respondent.understands_terms_of_court_order_details).to eq(sample_respondent.understands_terms_of_court_order_details)
      expect(respondent.warning_letter_sent).to eq(sample_respondent.warning_letter_sent)
      expect(respondent.warning_letter_sent_details).to eq(sample_respondent.warning_letter_sent_details)
      expect(respondent.police_notified).to eq(sample_respondent.police_notified)
      expect(respondent.police_notified_details).to eq(sample_respondent.police_notified_details)
      expect(respondent.bail_conditions_set).to eq(sample_respondent.bail_conditions_set)
      expect(respondent.bail_conditions_set_details).to eq(sample_respondent.bail_conditions_set_details)
    end

    context 'radio button are empty' do
      let(:custom_params) do
        {
          understands_terms_of_court_order: '',
          warning_letter_sent: '',
          police_notified: '',
          bail_conditions_set: ''
        }
      end

      it 'updates the respondent' do
        expect(respondent.understands_terms_of_court_order).to eq(nil)
        expect(respondent.warning_letter_sent).to eq(nil)
        expect(respondent.police_notified).to eq(nil)
        expect(respondent.bail_conditions_set).to eq(nil)
      end
    end

    context 'details are empty even though they should be present' do
      let(:custom_params) do
        {
          understands_terms_of_court_order: 'false',
          warning_letter_sent: 'false',
          police_notified: 'false',
          understands_terms_of_court_order_details: '',
          warning_letter_sent_details: '',
          police_notified_details: '',
          bail_conditions_set_details: ''
        }
      end

      it 'updates the respondent' do
        expect(respondent.understands_terms_of_court_order).to eq(false)
        expect(respondent.warning_letter_sent).to eq(false)
        expect(respondent.police_notified).to eq(false)
        expect(respondent.understands_terms_of_court_order_details).to eq(nil)
        expect(respondent.warning_letter_sent_details).to eq(nil)
        expect(respondent.police_notified_details).to eq(nil)
        expect(respondent.bail_conditions_set_details).to eq(nil)
      end
    end
  end
end
