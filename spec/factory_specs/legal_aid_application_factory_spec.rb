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

  describe ':with scope limitations' do
    context "don't specify proceeding types" do
      context "don't specify the number of proceeding types" do
        it 'creates one proceeding type' do
          application = create :application, :with_substantive_scope_limitation
          expect(ProceedingType.count).to eq 1
          proceeding_type = ProceedingType.first
          expect(application.proceeding_types).to eq [proceeding_type]
        end
      end
    end

    context 'specifying the proceeding types' do
      it 'creates the an application with the specified proceeding types' do
        pt1 = create :proceeding_type
        pt2 = create :proceeding_type
        application = create :legal_aid_application, :with_substantive_scope_limitation, proceeding_types: [pt1, pt2]
        expect(application.proceeding_types).to eq [pt1, pt2]
      end
    end

    context 'scope_limitations' do
      context 'without delegated functions' do
        let(:application) { create :application, :with_substantive_scope_limitation }
        let!(:proceeding_type) { application.lead_proceeding_type }
        it 'creates a default substantive scope limitation for the first proceeding type' do
          substantive_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, substantive_default: true)
          expect(substantive_default_sl_for_pt).not_to be_nil
        end

        it 'creates adds the default substantive scope limitation for the first proceeding type to the application' do
          substantive_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, substantive_default: true)
          expect(application.substantive_scope_limitation).to eq substantive_default_sl_for_pt.scope_limitation
        end

        it 'does not add a delegated function scope limitation to the application' do
          expect(application.delegated_functions_scope_limitation).to be_nil
        end
      end

      context 'with delegated functions' do
        let(:application) do
          create :application,
                 :with_delegated_functions,
                 :with_substantive_scope_limitation,
                 :with_delegated_functions_scope_limitation
        end
        let!(:proceeding_type) { application.lead_proceeding_type }

        it 'creates default substantive and delegated functions scope limitations for the first proceeding type' do
          substantive_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, substantive_default: true)
          delegated_functions_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, delegated_functions_default: true)
          expect(substantive_default_sl_for_pt).not_to be_nil
          expect(delegated_functions_default_sl_for_pt).not_to be_nil
        end

        it 'adds the default substantive scope limitation for the first proceeding type to the application' do
          substantive_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, substantive_default: true)
          expect(application.substantive_scope_limitation).to eq substantive_default_sl_for_pt.scope_limitation
        end

        it 'adds the default delegated_functions scope limitation for the first proceeding type to the application' do
          delegated_functions_default_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, delegated_functions_default: true)
          expect(application.delegated_functions_scope_limitation).to eq delegated_functions_default_sl_for_pt.scope_limitation
        end

        it 'adds a delegated function scope limitation to the application' do
          substantive_delegated_functions_sl_for_pt = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: proceeding_type.id, delegated_functions_default: true)
          expect(application.delegated_functions_scope_limitation).to eq substantive_delegated_functions_sl_for_pt.scope_limitation
        end
      end
    end
  end
end
