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
        expect(application_proceeding_type.lead_proceeding).to be true
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

      it 'creates record with multiple proceedings and assigns the first one as lead_proceeding' do
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.proceeding_types << proceeding_type2
        legal_aid_application.save!
        first_proceeding_type = legal_aid_application.application_proceeding_types.order(proceeding_case_id: :asc).first
        expect(first_proceeding_type.lead_proceeding).to be true
        second_proceeding_type = legal_aid_application.application_proceeding_types.order(proceeding_case_id: :asc).last
        expect(second_proceeding_type.lead_proceeding).to be false
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

  describe '#used_delegated_functions?' do
    let(:application) { create :legal_aid_application }

    before do
      create :application_proceeding_type, legal_aid_application: application, used_delegated_functions_on: nil
      create :application_proceeding_type, legal_aid_application: application, used_delegated_functions_on: df_date
      Setting.setting.update(allow_multiple_proceedings: true)
    end

    context 'delegated functions used' do
      let(:df_date) { Time.current }

      it 'returns true' do
        application_proceeding_type = application.application_proceeding_types.first
        expect(application_proceeding_type.used_delegated_functions?).to be true
      end
    end

    context 'delegated functions not used' do
      let(:df_date) { nil }

      it 'returns false' do
        application_proceeding_type = application.application_proceeding_types.first
        expect(application_proceeding_type.used_delegated_functions?).to be false
      end
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
          expect(application_proceeding_type.assigned_scope_limitations).to eq [default_scope_limitation, default_df_scope_limitation]
        end
      end

      context 'and add_default_delegated_functions_scope_limitation is called again' do
        before { application_proceeding_type.add_default_delegated_functions_scope_limitation }

        it 'ignores the duplicate request' do
          expect(application_proceeding_type.assigned_scope_limitations).to eq [default_scope_limitation, default_df_scope_limitation]
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
end
