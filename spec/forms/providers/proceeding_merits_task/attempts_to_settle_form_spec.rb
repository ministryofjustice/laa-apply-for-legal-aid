require 'rails_helper'

RSpec.describe Providers::ProceedingMeritsTask::AttemptsToSettleForm, type: :form do
  let(:params) { { attempts_made: attempts_made } }

  subject(:form) { described_class.new(params) }

  describe '#save' do
    context 'validation' do
      before { form.valid? }
      context 'when the parameters are populated' do
        let(:attempts_made) { 'some detail' }

        it { is_expected.to be_valid }
      end

      context 'when the parameters are missing' do
        let(:attempts_made) { '' }

        it { is_expected.to be_invalid }

        it 'records the error message' do
          expect(form.errors[:attempts_made]).to eq [I18n.t('providers.proceeding_merits_task.attempts_to_settle.show.error')]
        end
      end
    end
  end
end
