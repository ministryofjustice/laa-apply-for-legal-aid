require 'rails_helper'
require Rails.root.join('lib/tasks/helpers/scope_limitations_migrator')

RSpec.describe ScopeLimitationsMigrator do
  before { populate_legal_framework }

  let(:pt0220) { ProceedingType.find_by(code: 'PR0220') }
  let(:pt0206) { ProceedingType.find_by(code: 'PR0206') }
  let(:sl_subst_pt0220) { pt0220.default_substantive_scope_limitation }
  let(:sl_subst_pt0206) { pt0206.default_substantive_scope_limitation }
  let(:sl_df_pt0206) { pt0206.default_delegated_functions_scope_limitation }

  let!(:laa_no_proceeding_type) { create :legal_aid_application }
  let!(:laa_subst) do
    laa = create :legal_aid_application
    laa.proceeding_types << pt0220
    laa.scope_limitations << sl_subst_pt0220
    laa.save!
    laa
  end
  let!(:laa_df) do
    laa = create :legal_aid_application
    laa.proceeding_types << pt0206
    laa.scope_limitations << sl_subst_pt0206
    laa.scope_limitations << sl_df_pt0206
    laa.save!
    laa
  end

  context 'when the migrator hasnt been run already' do
    it 'has no assigned scope limitations' do
      expect(laa_no_proceeding_type.proceeding_types).to be_empty
      expect(laa_subst.application_proceeding_types.first.assigned_scope_limitations).to be_empty
      expect(laa_df.application_proceeding_types.first.assigned_scope_limitations).to be_empty
    end

    it 'migrates the old schema to the new' do
      expect { ScopeLimitationsMigrator.call }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(3)
      expect(laa_no_proceeding_type.application_proceeding_types).to be_empty
      expect(laa_subst.application_proceeding_types.first.assigned_scope_limitations).to eq [sl_subst_pt0220]
      expect(laa_df.application_proceeding_types.first.assigned_scope_limitations).to match_array [sl_subst_pt0206, sl_df_pt0206]
    end

    context 'application has duplicate scope limitations' do
      before { laa_df.scope_limitations << sl_df_pt0206 }

      it 'ignores the duplicate scope limtation' do
        expect(laa_df.proceeding_types.size).to eq 1
        expect(laa_df.scope_limitations.size).to eq 3
        expect { ScopeLimitationsMigrator.call }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(3)
        expect(laa_df.application_proceeding_types.first.assigned_scope_limitations.size).to eq 2
      end
    end
  end

  context 'when the migrator has already been run once' do
    before { ScopeLimitationsMigrator.call }

    it 'does not add any new records' do
      expect { ScopeLimitationsMigrator.call }.not_to change { ApplicationProceedingTypesScopeLimitation.count }
      expect(laa_no_proceeding_type.application_proceeding_types).to be_empty
      expect(laa_subst.application_proceeding_types.first.assigned_scope_limitations).to eq [sl_subst_pt0220]
      expect(laa_df.application_proceeding_types.first.assigned_scope_limitations).to match_array [sl_subst_pt0206, sl_df_pt0206]
    end
  end
end
