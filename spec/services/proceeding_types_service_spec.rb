require 'rails_helper'

RSpec.describe ProceedingTypesService do
  let!(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let!(:proceeding_type) { create :proceeding_type }
  let!(:default_substantive_scope_limitation) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }

  subject { described_class.new(legal_aid_application) }

  describe '#add' do
    context 'correct params' do
      let(:scope_limitation) { :substantive }
      let(:params) do
        {
          proceeding_type_id: proceeding_type.id,
          scope_limitation: scope_limitation
        }
      end

      it 'adds a proceeding type' do
        subject.add(**params)
        puts 1111
        puts legal_aid_application.proceeding_types
        puts 2222
        puts proceeding_type
        expect(legal_aid_application.proceeding_types).to include(proceeding_type)
      end

      context 'proceeding types already exist' do
        context 'Setting.allow_multiple_proceedings? returns true' do
          let(:legal_aid_application) { create :legal_aid_application, :with_applicant, proceeding_types: [proceeding_type] }
          let(:proceeding_type2) { create :proceeding_type }
          let(:params) do
            {
              proceeding_type_id: proceeding_type2.id,
              scope_limitation: scope_limitation
            }
          end

          before do
            allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true)
          end

          it 'adds another proceeding type' do
            subject.add(**params)
            expect(legal_aid_application.proceeding_types).to eq([proceeding_type, proceeding_type2])
          end
        end

        context 'Setting.allow_multiple_proceedings? returns false' do
          let(:legal_aid_application) { create :legal_aid_application, :with_applicant, proceeding_types: [proceeding_type1] }
          let(:proceeding_type1) { create :proceeding_type }
          let(:proceeding_type2) { create :proceeding_type }
          let!(:default_substantive_scope_limitation) do
            create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type2, meaning: 'Default substantive SL'
          end
          let(:params) do
            {
              proceeding_type_id: proceeding_type2.id,
              scope_limitation: scope_limitation
            }
          end

          before do
            allow(Setting).to receive(:allow_multiple_proceedings?).and_return(false)
          end

          it 'replaces the application proceeding type' do
            expect(legal_aid_application.proceeding_types).to eq([proceeding_type1])
            subject.add(**params)
            expect(legal_aid_application.proceeding_types).to eq([proceeding_type2])
          end
        end
      end

      it 'calls AddScopeLimitationService' do
        expect(AddScopeLimitationService).to receive(:call).with(legal_aid_application, scope_limitation)
        subject.add(**params)
      end
    end

    context 'on failure' do
      let(:scope_limitation) { nil }
      let(:params) do
        {
          proceeding_type_id: proceeding_type.id,
          scope_limitation: scope_limitation
        }
      end

      it 'returns false' do
        expect(subject.add(**params)).to eq false
      end

      it 'does not call AddScopeLimitationService' do
        expect(AddScopeLimitationService).not_to receive(:call).with(legal_aid_application, scope_limitation)
        subject.add(**params)
      end
    end
  end
end
