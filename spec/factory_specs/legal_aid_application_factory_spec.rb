require 'rails_helper'

RSpec.describe 'LegalAidApplication factory' do
  describe ':with_bank_accounts' do
    context 'when used with :with_applicant' do
      context 'with applicant not specified' do
        it 'has no applicant' do
          legal_aid_application = create :legal_aid_application
          expect(legal_aid_application.applicant).to be_nil
        end
      end

      context ':with_applicant specified' do
        context ':with_bank_accounts not specified' do
          it 'has an applicant but no bank accounts' do
            legal_aid_application = create :legal_aid_application, :with_applicant
            expect(legal_aid_application.applicant).to be_present
            expect(legal_aid_application.applicant.bank_accounts).to be_empty
          end
        end

        context ':with_bank_accounts specified' do
          it 'has the specified number of bank accunts' do
            legal_aid_application = create :legal_aid_application, :with_applicant, with_bank_accounts: 3
            expect(legal_aid_application.applicant).to be_present
            expect(legal_aid_application.applicant.bank_accounts.size).to eq 3
          end
        end
      end
    end

    describe 'when used :with_everything' do
      context ':with_bank_accounts not specified' do
        it 'creates applicant but no bank accounts' do
          legal_aid_application = create :legal_aid_application, :with_everything
          expect(legal_aid_application.applicant).to be_present
          expect(legal_aid_application.applicant.bank_accounts).to be_empty
        end
      end

      context ':with_bank_accounts specified' do
        it 'creates applicant and the specified number of bank accounts' do
          legal_aid_application = create :legal_aid_application, :with_everything, with_bank_accounts: 2
          expect(legal_aid_application.applicant).to be_present
          expect(legal_aid_application.applicant.bank_accounts.size).to eq 2
        end
      end
    end
  end

  describe 'with_proceeding_types' do
    context 'proceeding type count not specified' do
      let(:laa) { create :legal_aid_application, :with_proceeding_types }
      let(:apt) { laa.application_proceeding_types.first }
      let(:proceeding_type) { laa.proceeding_types.first }

      it 'creates an application with one proceeding type with two scope limitations' do
        expect(laa.proceeding_types.count).to eq 1
        expect(ProceedingType.count).to eq 1
        expect(ScopeLimitation.count).to eq 2
      end

      it 'creates assigns the default substantive scope limitation to the application_proceeding_type' do
        expect(proceeding_type.default_substantive_scope_limitation).not_to be_nil
        expect(proceeding_type.default_delegated_functions_scope_limitation).not_to be_nil
        default_sl = proceeding_type.default_substantive_scope_limitation
        expect(apt.assigned_scope_limitations.size).to eq 1
        expect(apt.assigned_scope_limitations.first).to eq default_sl
      end

      it 'creates application proceeding types with nil df dates' do
        expect(apt.used_delegated_functions_on).to be_nil
        expect(apt.used_delegated_functions_reported_on).to be_nil
      end
    end

    context 'proceeding type count more than 1' do
      let(:laa) { create :legal_aid_application, :with_proceeding_types, proceeding_types_count: 3 }

      before { laa }

      it 'creates an application with three proceeding type' do
        expect(laa.proceeding_types.count).to eq 3
        expect(ProceedingType.count).to eq 3
      end

      it 'creates a substantive and df scope limitation for each proceeding type' do
        expect(laa.application_proceeding_types.count).to eq 3
        laa.application_proceeding_types.each do |apt|
          expect(apt.assigned_scope_limitations.count).to eq 1
          expect(apt.substantive_scope_limitation).not_to be_nil
          expect(apt.delegated_functions_scope_limitation).to be_nil
        end
      end
    end

    context 'explicit proceeding types' do
      let(:pt1) { create :proceeding_type, :with_real_data, :with_scope_limitations }
      let(:pt2) { create :proceeding_type, :as_occupation_order, :with_scope_limitations }
      let(:laa) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt1, pt2] }
      let(:apts) { laa.application_proceeding_types }

      it 'has two apt records pointing to the explicitly specified proceeding types' do
        expect(apts.size).to eq 2
        expect(apts.map(&:proceeding_type)).to match_array [pt1, pt2]
      end

      it 'creates nil df dates on all apt records' do
        expect(apts.map(&:used_delegated_functions_on)).to eq [nil, nil]
        expect(apts.map(&:used_delegated_functions_reported_on)).to eq [nil, nil]
      end

      it 'links the default substantive scope limitation of each proceeding type to the relevant apt' do
        apts.each do |apt|
          pt = apt.proceeding_type
          expect(apt.substantive_scope_limitation).to eq pt.default_substantive_scope_limitation
        end
      end

      it 'does not link the delegated functions default scope limitation' do
        expect(apts.map(&:delegated_functions_scope_limitation)).to eq [nil, nil]
      end
    end
  end

  describe ':with proceeding types, :with_delegated_functions' do
    let(:laa) do
      create :legal_aid_application,
             :with_proceeding_types,
             :with_delegated_functions,
             proceeding_types_count: 3,
             delegated_functions_date: [5.days.ago, 4.days.ago]
    end
    let(:apts) { laa.application_proceeding_types }

    it 'creates three apt records with df dates of 5 days ago, 4 days ago and today' do
      expect(apts.size).to eq 3
      expect(apts.map(&:used_delegated_functions_on)).to match_array [5.days.ago.to_date, 4.days.ago.to_date, Date.current]
      expect(apts.map(&:used_delegated_functions_reported_on)).to match_array [Date.current, Date.current, Date.current]
    end

    it 'links the default delegated_functions scope limitation to the relevant apt' do
      laa.reload
      apts.each do |apt|
        expect(apt.delegated_functions_scope_limitation).to eq apt.proceeding_type.default_delegated_functions_scope_limitation
      end
    end
  end

  describe ':with_multiple_proceeding_types' do
    context 'not specifying the proceeding types' do
      let(:laa) { create :legal_aid_application, :with_multiple_proceeding_types }
      subject { laa }

      it 'seeds Proceeding Types with two real items' do
        subject
        expect(ProceedingType.order(:code).pluck(:code)).to eq %w[PR0208 PR0214]
      end

      it 'attached both real items to the application' do
        expect(laa.proceeding_types.order(:code).map(&:code)).to eq %w[PR0208 PR0214]
      end

      it 'populates scope limitations table with one dummy scope limitation' do
        expect(ScopeLimitation.count).to eq 0
        subject
        expect(ScopeLimitation.count).to eq 1
      end

      it 'attaches the scope limitation to the lead proceeding type as the default substantive' do
        subject
        expect(ProceedingTypeScopeLimitation.count).to eq 1
        expect(laa.proceeding_types.first.default_substantive_scope_limitation).to eq ScopeLimitation.first
      end

      it 'assigns the scope limitation to the application_proceeding_type' do
        expect { subject }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(1)
        lead_pt = laa.lead_proceeding_type
        apt = laa.reload.application_proceeding_types.find_by(proceeding_type_id: lead_pt.id)
        aptsl = ApplicationProceedingTypesScopeLimitation.find_by(application_proceeding_type_id: apt.id)
        expect(aptsl).to be_instance_of(AssignedSubstantiveScopeLimitation)
        expect(aptsl.scope_limitation_id).to eq ScopeLimitation.first.id
      end
    end

    context 'specifying the proceeding types' do
      let!(:pt1) { create :proceeding_type }
      let!(:pt2) { create :proceeding_type }
      let(:laa) { create :legal_aid_application, :with_multiple_proceeding_types, proceeding_types: [pt1, pt2] }

      subject { laa }

      it 'does not create any more proceeding type records' do
        expect(ProceedingType.count).to eq 2
        expect { subject }.not_to change { ProceedingType.count }
      end

      it 'creates one scope limitation and adds it to the lead proceeding types eligible scope limitaions' do
        expect(ScopeLimitation.count).to be 0
        expect { subject }.to change { ScopeLimitation.count }.by(1)
        expect(laa.lead_proceeding_type.eligible_scope_limitations.first).to eq ScopeLimitation.first
      end

      it 'assigns the scope to the application  lead processing type' do
        expect { subject }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(1)
        lead_pt = laa.lead_proceeding_type
        apt = laa.reload.application_proceeding_types.find_by(proceeding_type_id: lead_pt.id)
        aptsl = ApplicationProceedingTypesScopeLimitation.find_by(application_proceeding_type_id: apt.id)
        expect(aptsl).to be_instance_of(AssignedSubstantiveScopeLimitation)
        expect(aptsl.scope_limitation_id).to eq ScopeLimitation.first.id
      end
    end
  end

  describe ':with_substantive_scope_limitation' do
    context 'without specifying proceeding type' do
      let(:laa) { create :legal_aid_application, :with_substantive_scope_limitation }

      subject { laa }

      it 'creates a proceeding type and adds it to the application' do
        expect(ProceedingType.count).to eq 0
        expect { subject }.to change { ProceedingType.count }.by(1)
        expect(laa.lead_proceeding_type).to eq ProceedingType.first
      end

      it 'creates a default scope limitation and adds to the lead proceeding type' do
        expect(ScopeLimitation.count).to eq 0
        expect { subject }.to change { ScopeLimitation.count }.by(1)
        expect(laa.lead_proceeding_type.eligible_scope_limitations).to eq [ScopeLimitation.first]
        expect(laa.lead_proceeding_type.default_substantive_scope_limitation).to eq ScopeLimitation.first
      end

      it 'assigns the scope limtiation to the lead proceeding type' do
        expect { subject }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(1)
        lead_pt = laa.lead_proceeding_type
        apt = laa.reload.application_proceeding_types.find_by(proceeding_type_id: lead_pt.id)
        aptsl = ApplicationProceedingTypesScopeLimitation.find_by(application_proceeding_type_id: apt.id)
        expect(aptsl).to be_instance_of(AssignedSubstantiveScopeLimitation)
        expect(aptsl.scope_limitation_id).to eq ScopeLimitation.first.id
      end
    end
  end

  describe ':with_proceeding_type_and_scope_limitations' do
    let(:pt1) { create :proceeding_type }
    let(:sl1) { create :scope_limitation }
    let(:sl2) { create :scope_limitation }

    let(:apt) { laa.application_proceeding_types.first }

    context 'initial state' do
      before { [pt1, sl1, sl2] }
      it 'has no links between the proceeding types and scope limitations' do
        expect(ProceedingType.count).to eq 1
        expect(ProceedingType.first).to eq pt1

        expect(ScopeLimitation.count).to eq 2
        expect(ScopeLimitation.pluck(:id)).to match_array [sl1.id, sl2.id]

        expect(ProceedingTypeScopeLimitation.count).to be 0
      end
    end

    context 'specifying both substantive and df scope limitations' do
      let(:laa) do
        create :legal_aid_application,
               :with_proceeding_type_and_scope_limitations,
               this_proceeding_type: pt1,
               substantive_scope_limitation: sl1,
               df_scope_limitation: sl2
      end
      before { laa }

      it 'attaches the subst scope limitation to the proceeding type as a default' do
        expect(pt1.default_substantive_scope_limitation).to eq sl1
      end

      it 'attaches the df scope limtation as the proceeding type as a default' do
        expect(pt1.default_delegated_functions_scope_limitation).to eq sl2
      end

      it 'assigns both scope limitations to the application proceeding type' do
        expect(apt.assigned_scope_limitations).to match_array [sl1, sl2]
      end

      it 'assigns the substantive scope limitation to the application_proceeding_type' do
        expect(apt.substantive_scope_limitation).to eq sl1
      end

      it 'assigns the df scope limitation to the application proceeding type' do
        expect(apt.delegated_functions_scope_limitation).to eq sl2
      end
    end

    context 'specifying only substantive scope limitation' do
      let(:laa) do
        create :legal_aid_application,
               :with_proceeding_type_and_scope_limitations,
               this_proceeding_type: pt1,
               substantive_scope_limitation: sl1
      end
      before { laa }

      it 'attaches the subst scope limitation to the proceeding type as a default' do
        expect(pt1.default_substantive_scope_limitation).to eq sl1
      end

      it 'does not attach a default delegated functions scope limitation to the proceeding type' do
        expect(pt1.default_delegated_functions_scope_limitation).to be_nil
      end

      it 'assigns the substantive scope limitations to the application proceeding type' do
        expect(apt.assigned_scope_limitations).to match_array [sl1]
      end

      it 'assigns the substantive scope limitations to the application_proceeding_type' do
        expect(apt.substantive_scope_limitation).to eq sl1
      end

      it 'does not assign the df scope limitation to the application proceeding type' do
        expect(apt.delegated_functions_scope_limitation).to be nil
      end
    end
  end
end
