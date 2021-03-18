require 'rails_helper'

RSpec.describe Opponents::OpponentForm, type: :form do
  let(:opponent) { create :opponent }
  let(:custom_params) { {} }
  let(:sample_params) do
    {
      'understands_terms_of_court_order' => 'false',
      'understands_terms_of_court_order_details' => 'New understands terms of court order details',
      'warning_letter_sent' => 'false',
      'warning_letter_sent_details' => 'New warning letter sent details',
      'police_notified' => 'true',
      'police_notified_details_true' => 'Reasons police not notified details',
      'bail_conditions_set' => 'true',
      'bail_conditions_set_details' => 'New bail conditions set details',
      'full_name' => 'Hiram Schulist'
    }
  end
  let(:i18n_scope) { 'activemodel.errors.models.application_merits_task/opponent.attributes' }
  let(:custom_params) { {} }

  subject { described_class.new(sample_params.merge(custom_params).merge(model: opponent)) }

  describe 'extrapolate_police_notified_details' do
    context 'when loaded via params' do
      subject { described_class.new(params) }
      let(:params) do
        {
          understands_terms_of_court_order: 'false',
          understands_terms_of_court_order_details: 'terms of court order details ',
          warning_letter_sent: 'false',
          warning_letter_sent_details: 'warning letter sent details',
          police_notified: police_notified,
          police_notified_details: police_notified_details,
          bail_conditions_set: 'true',
          bail_conditions_set_details: 'bail condition set details',
          full_name: 'Bob Smith'
        }
      end

      context 'with police_notified false' do
        let(:police_notified) { 'false' }
        let(:police_notified_details) { 'reasons police not told' }

        it 'extrapolates the police_notified_details for display on the page' do
          expect(subject.police_notified).to eq 'false'
          expect(subject.police_notified_details_false).to eq 'reasons police not told'
          expect(subject.police_notified_details_true).to eq nil
        end
      end

      context 'with police_notified true' do
        let(:police_notified) { 'true' }
        let(:police_notified_details) { 'reasons police told' }

        it 'extrapolates the police_notified_details for display on the page' do
          expect(subject.police_notified).to eq 'true'
          expect(subject.police_notified_details_false).to eq nil
          expect(subject.police_notified_details_true).to eq 'reasons police told'
        end
      end
    end
  end

  describe '#save' do
    before do
      subject.save
      opponent.reload
    end

    it 'updates the opponent' do
      expect(opponent.understands_terms_of_court_order).to eq(false)
      expect(opponent.understands_terms_of_court_order_details).to eq(sample_params['understands_terms_of_court_order_details'])
      expect(opponent.warning_letter_sent).to eq(false)
      expect(opponent.warning_letter_sent_details).to eq(sample_params['warning_letter_sent_details'])
      expect(opponent.police_notified).to eq(true)
      expect(opponent.police_notified_details).to eq(sample_params['police_notified_details_true'])
      expect(opponent.bail_conditions_set).to eq(true)
      expect(opponent.bail_conditions_set_details).to eq(sample_params['bail_conditions_set_details'])
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

      it 'updates the opponent' do
        expect(opponent.understands_terms_of_court_order).to eq(true)
        expect(opponent.warning_letter_sent).to eq(true)
        expect(opponent.understands_terms_of_court_order_details).to eq('')
        expect(opponent.warning_letter_sent_details).to eq('')
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
          police_notified: 'true',
          bail_conditions_set: 'true',
          understands_terms_of_court_order_details: '',
          warning_letter_sent_details: '',
          police_notified_details_true: '',
          bail_conditions_set_details: ''
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates errors' do
        expect(subject.errors[:understands_terms_of_court_order_details].join).to eq(I18n.t('understands_terms_of_court_order_details.blank', scope: i18n_scope))
        expect(subject.errors[:warning_letter_sent_details].join).to eq(I18n.t('warning_letter_sent_details.blank', scope: i18n_scope))
        expect(subject.errors[:police_notified_details_true].join).to eq(I18n.t('activemodel.errors.models.opponent.attributes.police_notified_details_true.blank'))
        expect(subject.errors[:bail_conditions_set_details].join).to eq(I18n.t('bail_conditions_set_details.blank', scope: i18n_scope))
      end

      it 'generates errors in the right order' do
        expect(subject.errors.attribute_names).to eq(
          %i[
            understands_terms_of_court_order_details
            warning_letter_sent_details
            police_notified_details_true
            bail_conditions_set_details
          ]
        )
      end
    end
  end

  describe '#save_as_draft' do
    before do
      subject.save_as_draft
      opponent.reload
    end

    it 'updates the opponent' do
      expect(opponent.understands_terms_of_court_order).to eq(false)
      expect(opponent.understands_terms_of_court_order_details).to eq(sample_params['understands_terms_of_court_order_details'])
      expect(opponent.warning_letter_sent).to eq(false)
      expect(opponent.warning_letter_sent_details).to eq(sample_params['warning_letter_sent_details'])
      expect(opponent.police_notified).to eq(true)
      expect(opponent.police_notified_details).to eq(sample_params['police_notified_details_true'])
      expect(opponent.bail_conditions_set).to eq(true)
      expect(opponent.bail_conditions_set_details).to eq(sample_params['bail_conditions_set_details'])
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

      it 'updates the opponent' do
        expect(opponent.understands_terms_of_court_order).to eq(nil)
        expect(opponent.warning_letter_sent).to eq(nil)
        expect(opponent.police_notified).to eq(nil)
        expect(opponent.bail_conditions_set).to eq(nil)
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
          police_notified_details_false: '',
          bail_conditions_set_details: ''
        }
      end

      it 'updates the opponent' do
        expect(opponent.understands_terms_of_court_order).to eq(false)
        expect(opponent.warning_letter_sent).to eq(false)
        expect(opponent.police_notified).to eq(false)
        expect(opponent.understands_terms_of_court_order_details).to eq(nil)
        expect(opponent.warning_letter_sent_details).to eq(nil)
        expect(opponent.police_notified_details).to eq(nil)
        expect(opponent.bail_conditions_set_details).to eq(nil)
      end
    end
  end
end
