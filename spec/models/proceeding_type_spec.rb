require 'rails_helper'

RSpec.describe ProceedingType, type: :model do
  let!(:proceeding_type) { ProceedingType.create(code: 'PH0001') }

  it 'proceeding_type should have code' do
    expect(proceeding_type.code).not_to be_nil
  end

  describe 'should have associations with legal_aid_application' do
    it { should have_many(:legal_aid_applications) }
  end

  describe 'should have associations with scope_limitation' do
    it { should have_many(:eligible_scope_limitations) }
  end

  describe 'should have associations with service_level' do
    it { should belong_to(:default_level_of_service).class_name('ServiceLevel') }
  end

  describe '.populate' do
    it 'calls the proceeding_type_populator service' do
      expect(ProceedingTypePopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end

  describe '#default_scope_limitation' do
    let!(:proceeding_type) { create :proceeding_type }
    let!(:sl_substantive_default) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }
    let!(:sl_delegated_default) { create :scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type, meaning: 'Default delegated functions SL' }
    let!(:sl_non_default) { create :scope_limitation }

    context 'for substantive applications' do
      it 'returns the default substantive scope limitation' do
        expect(proceeding_type.default_substantive_scope_limitation).to eq sl_substantive_default
      end
    end

    context 'for delegated functions applications' do
      it 'returns the default delegated functions scope limitation' do
        expect(proceeding_type.default_delegated_functions_scope_limitation).to eq sl_delegated_default
      end
    end
  end

  describe '#domestic_abuse?' do
    let(:proceeding_type) { create :proceeding_type, ccms_matter: matter }
    context 'domestic abuse' do
      let(:matter) { 'Domestic Abuse' }
      it 'returns true' do
        expect(proceeding_type.domestic_abuse?).to be true
      end
    end

    context 'not domestic abuse' do
      let(:matter) { 'Something Else' }
      it 'returns false' do
        expect(proceeding_type.domestic_abuse?).to be false
      end
    end
  end

  describe '#section8?' do
    let(:proceeding_type) { create :proceeding_type, ccms_matter: matter }
    context 'section 8' do
      let(:matter) { 'Section 8 orders' }
      it 'returns true' do
        expect(proceeding_type.section8?).to be true
      end
    end

    context 'not section 8' do
      let(:matter) { 'Domestic Abuse' }
      it 'returns false' do
        expect(proceeding_type.section8?).to be false
      end
    end
  end

  context 'cost limitations' do
    let(:pt) { create :proceeding_type }
    let(:old_start_date) { Date.parse('1970-01-01') }
    let(:new_start_date) { Date.parse('2021-09-13') }

    before do
      create :default_cost_limitation, :substantive, proceeding_type: pt
      create :default_cost_limitation, :original_df, proceeding_type: pt
      create :default_cost_limitation, :revised_df, proceeding_type: pt
    end

    around do |example|
      travel_to run_date
      example.run
      travel_back
    end

    describe 'before the change' do
      let(:run_date) { Date.parse('2021-09-11') }

      it 'returns the old values' do
        expect(pt.default_cost_limitation_substantive).to eq 25_000.0
        expect(pt.default_cost_limitation_delegated_functions).to eq 1350.0
      end
    end

    describe 'after the change' do
      let(:run_date) { Date.parse('2021-09-13') }

      it 'returns the old values' do
        expect(pt.default_cost_limitation_substantive).to eq 25_000.0
        expect(pt.default_cost_limitation_delegated_functions).to eq 2250.0
      end
    end
  end
end
