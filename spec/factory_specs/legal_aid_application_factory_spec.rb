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
          it 'has the specified number of bank accounts' do
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
