require 'rails_helper'

RSpec.describe ApplicationProceedingType do
  describe '#proceeding_case_id' do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:proceeding_type) { create :proceeding_type }
    let(:proceeding_type2) { create :proceeding_type }

    context 'empty_database' do
      it 'creates record with first proceeding case id' do
        expect(ApplicationProceedingType.count).to be_zero
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.save!
        application_proceeding_type = legal_aid_application.application_proceeding_types.first
        expect(application_proceeding_type.proceeding_case_id > 55_000_000).to be true
      end
    end

    context 'database with records' do
      it 'creates a record with the next in sequence' do
        3.times { create :legal_aid_application, :with_proceeding_types }
        expect(ApplicationProceedingType.count).to eq 3
        highest_proceeding_case_id = ApplicationProceedingType.order(:proceeding_case_id).last.proceeding_case_id
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.save!
        application_proceeding_type = legal_aid_application.application_proceeding_types.first
        expect(application_proceeding_type.proceeding_case_id).to eq highest_proceeding_case_id + 1
      end
    end
  end

  describe '#proceeding_case_p_num' do
    it 'prefixes the proceeding case id with P_' do
      legal_aid_application = create :legal_aid_application, :with_proceeding_types
      application_proceeding_type = legal_aid_application.application_proceeding_types.first
      allow(application_proceeding_type).to receive(:proceeding_case_id).and_return 55_200_301
      expect(application_proceeding_type.proceeding_case_p_num).to eq 'P_55200301'
    end
  end

  describe 'delegated functions' do
    let(:application) do
      create :legal_aid_application,
             :with_proceeding_types,
             :with_delegated_functions,
             delegated_functions_date: df_date,
             delegated_functions_reported_date: df_reported_date
    end
    let(:df_date) { Date.current - 10.days }
    let(:df_reported_date) { Date.current }

    before do
      Setting.setting.update(allow_multiple_proceedings: true)
    end

    context 'delegated functions used' do
      it 'used delegated functions returns true' do
        application_proceeding_type = application.application_proceeding_types.first
        expect(application_proceeding_type.used_delegated_functions?).to be true
      end

      it 'returns the earliest delegated functions date' do
        expect(application.earliest_delegated_functions_date).to eq df_date
      end

      it 'returns the earliest delegated functions reported date' do
        expect(application.earliest_delegated_functions_reported_date).to eq df_reported_date
      end
    end

    context 'delegated functions not used' do
      before do
        application.application_proceeding_types.each do |apt|
          apt.update!(used_delegated_functions_on: nil,
                      used_delegated_functions_reported_on: nil)
        end
      end
      it 'used delegated functions returns false' do
        expect(application.used_delegated_functions?).to be false
      end
    end
  end

  describe 'scope using_delegated_functions' do
    let(:laa) { create :legal_aid_application }
    let!(:apt1) { create :application_proceeding_type, legal_aid_application: laa, used_delegated_functions_on: Time.zone.today }
    let!(:apt2) { create :application_proceeding_type, legal_aid_application: laa, used_delegated_functions_on: Time.zone.yesterday }
    let!(:apt3) { create :application_proceeding_type, legal_aid_application: laa }
    let(:records) { laa.application_proceeding_types.using_delegated_functions }

    it 'returns 2 records with DF dates, in date order' do
      expect(records).to eq [apt2, apt1]
    end
  end

  describe 'assigned_scope_limitations' do
    let(:application) { create :legal_aid_application }
    let(:proceeding_type) { ProceedingType.first }
    let(:application_proceeding_type) { application.application_proceeding_types.first }
    let(:default_scope_limitation) { proceeding_type.default_substantive_scope_limitation }
    let(:default_df_scope_limitation) { proceeding_type.default_delegated_functions_scope_limitation }
    let(:assigned_scope_limitation) { application_proceeding_type.assigned_scope_limitations.first }

    before do
      populate_legal_framework
      application.proceeding_types << proceeding_type
    end

    it 'adds the correct substantive scope limitation' do
      application_proceeding_type.add_default_substantive_scope_limitation
      expect(assigned_scope_limitation).to eq(default_scope_limitation)
    end

    it 'adds the correct default scope limitation' do
      application_proceeding_type.add_default_delegated_functions_scope_limitation
      expect(assigned_scope_limitation).to eq(default_df_scope_limitation)
    end

    context 'when the defaults have already been created' do
      # simulates the user pushing the back button and re-submitting the DF page
      before do
        application_proceeding_type.add_default_substantive_scope_limitation
        application_proceeding_type.add_default_delegated_functions_scope_limitation
      end

      context 'and add_default_substantive_scope_limitation is called again' do
        before { application_proceeding_type.add_default_substantive_scope_limitation }

        it 'ignores the duplicate request' do
          expect(application_proceeding_type.assigned_scope_limitations).to match_array [default_scope_limitation, default_df_scope_limitation]
        end
      end

      context 'and add_default_delegated_functions_scope_limitation is called again' do
        before { application_proceeding_type.add_default_delegated_functions_scope_limitation }

        it 'ignores the duplicate request' do
          expect(application_proceeding_type.assigned_scope_limitations).to match_array([default_scope_limitation, default_df_scope_limitation])
        end
      end
    end

    context 'deleting default delegated functions scope' do
      context 'when delegated functions exist' do
        before do
          application_proceeding_type.add_default_substantive_scope_limitation
          application_proceeding_type.add_default_delegated_functions_scope_limitation
        end

        it 'removes the delegated functions  scope' do
          application_proceeding_type.remove_default_delegated_functions_scope_limitation
          expect(application_proceeding_type.assigned_scope_limitations).to eq [default_scope_limitation]
        end
      end

      context 'when delegated functions do not exist' do
        before do
          application_proceeding_type.add_default_substantive_scope_limitation
        end

        it 'makes no changes to scope' do
          application_proceeding_type.remove_default_delegated_functions_scope_limitation
          expect(application_proceeding_type.assigned_scope_limitations).to eq [default_scope_limitation]
        end
      end
    end
  end

  describe 'involved children' do
    let(:application1) { create :legal_aid_application }
    let(:application2) { create :legal_aid_application }
    let(:proceeding_type1) { ProceedingType.first }
    let(:proceeding_type2) { ProceedingType.last }
    let(:application_proceeding_type1) { application1.application_proceeding_types.first }
    let(:application_proceeding_type2) { application2.application_proceeding_types.first }
    let(:application_involved_child1) { ApplicationMeritsTask::InvolvedChild.create(full_name: 'John Smith', date_of_birth: 1.month.ago, legal_aid_application: application1) }
    let(:application_involved_child2) { ApplicationMeritsTask::InvolvedChild.create(full_name: 'Mary Smith', date_of_birth: 1.month.ago, legal_aid_application: application2) }

    before do
      populate_legal_framework
      application1.proceeding_types << proceeding_type1
    end

    it 'adds involved children to the application proceeding type' do
      application_proceeding_type1.involved_children << application_involved_child1
      expect(application_proceeding_type1.involved_children.first.full_name).to eq('John Smith')
    end

    it 'does not allow other application involved children be present' do
      expect {
        application_proceeding_type1.involved_children << application_involved_child2
      }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Involved child belongs to another application'
    end
  end

  describe 'lead proceeding validation' do
    let(:proceeding_types) { create_list :proceeding_type, 3, :domestic_abuse }
    let!(:laa) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: proceeding_types, assign_lead_proceeding: false }
    let(:new_pt) { create :proceeding_type }
    let(:new_apt) { build :application_proceeding_type, proceeding_type: new_pt, legal_aid_application: laa, lead_proceeding: lead_proceeding }

    context 'lead proceeding on this record set to false' do
      let(:lead_proceeding) { false }

      context 'other lead proceeding exists' do
        before do
          laa.application_proceeding_types.first.update!(lead_proceeding: true)
          laa.reload
        end

        it 'is valid' do
          expect(new_apt).to be_valid
        end
      end

      context 'other lead proceeding doesnt exist' do
        it 'is valid' do
          expect(new_apt).to be_valid
        end
      end
    end

    context 'lead proceeding on this record set to true' do
      let(:lead_proceeding) { true }

      context 'this record already exists as the lead proceeding' do
        before do
          laa.application_proceeding_types.last.update!(lead_proceeding: true)
          laa.reload
        end

        it 'is valid' do
          apt = laa.application_proceeding_types.find_by(lead_proceeding: true)
          apt.used_delegated_functions_on = Date.current
          expect(apt).to be_valid
        end
      end

      context 'other lead proceeding exists' do
        before do
          laa.application_proceeding_types.last.update!(lead_proceeding: true)
          laa.reload
        end

        it 'is not valid' do
          expect(Sentry).to receive(:capture_message).with(/^Duplicate lead proceedings detected for application/)
          new_apt.save!
        end
      end

      context 'no other lead proceeding exists' do
        let(:lead_proceeding) { false }
        it 'does not capture a Sentry message' do
          expect(Sentry).not_to receive(:capture_message)
          new_apt.save!
        end
      end
    end
  end
end
