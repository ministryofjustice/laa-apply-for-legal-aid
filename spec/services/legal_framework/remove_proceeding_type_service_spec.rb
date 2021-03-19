require 'rails_helper'

module LegalFramework
  RSpec.describe RemoveProceedingTypeService do
    describe '.call' do
      let(:pt1) { create :proceeding_type }
      let(:sl1) { create :scope_limitation }
      let(:sl2) { create :scope_limitation }

      subject { RemoveProceedingTypeService.call(laa, pt1) }

      before { laa }

      context 'when proceeding type has only substantive scope limitation' do
        let(:laa) do
          create :legal_aid_application,
                 :with_proceeding_type_and_scope_limitations,
                 this_proceeding_type: pt1,
                 substantive_scope_limitation: sl1
        end

        it 'deletes the application_proceeding_type_scope_limitation record' do
          expect { subject }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(-1)
        end

        it 'deletes the application_proceeding_type record' do
          expect { subject }.to change { ApplicationProceedingType.count }.by(-1)
          expect(laa.application_proceeding_types.find_by(proceeding_type_id: pt1.id)).to be_nil
        end

        it 'does not delete the underlying proceeding type' do
          subject
          expect(ProceedingType.find(pt1.id)).to eq pt1
        end

        it 'does not delete the underlying scope limitation' do
          subject
          expect(ScopeLimitation.find(sl1.id)).to eq sl1
        end
      end

      context 'when proceeding type has both substantive and df scope limitations' do
        let(:laa) do
          create :legal_aid_application,
                 :with_proceeding_type_and_scope_limitations,
                 this_proceeding_type: pt1,
                 substantive_scope_limitation: sl1,
                 df_scope_limitation: sl2
        end

        it 'deletes both application_proceeding_type_scope_limitation record' do
          expect { subject }.to change { ApplicationProceedingTypesScopeLimitation.count }.by(-2)
        end

        it 'deletes the application_proceeding_type record' do
          expect { subject }.to change { ApplicationProceedingType.count }.by(-1)
          expect(laa.application_proceeding_types.find_by(proceeding_type_id: pt1.id)).to be_nil
        end

        it 'does not delete the underlying proceeding type' do
          subject
          expect(ProceedingType.find(pt1.id)).to eq pt1
        end

        it 'does not delete either of the underlying scope limitation' do
          subject
          expect(ScopeLimitation.find(sl1.id)).to eq sl1
          expect(ScopeLimitation.find(sl2.id)).to eq sl2
        end
      end
    end
  end
end
