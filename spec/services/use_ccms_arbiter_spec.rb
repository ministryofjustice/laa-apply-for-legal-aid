require 'rails_helper'

RSpec.describe UseCCMSArbiter do
  let(:laa) { create :legal_aid_application, :with_applicant, :applicant_details_checked }
  let(:provider) { laa.provider }
  let(:applicant) { laa.applicant }

  before do
    allow(laa).to receive(:applicant_receives_benefit?).and_return(receives_benefit)
    allow(provider).to receive(:passported_permissions?).and_return(provider_passported_permission)
    allow(provider).to receive(:non_passported_permissions?).and_return(provider_non_passported_permission)
  end

  subject { described_class.call(laa) }

  context 'applicant receives benefit' do
    let(:receives_benefit) { true }

    context 'provider does not have non-passported permissions' do
      let(:provider_non_passported_permission) { false }
      context 'provider has passported permissions' do
        let(:provider_passported_permission) { true }
        it 'returns false' do
          expect(subject).to be false
        end

        it 'has not changed the state' do
          subject
          expect(laa.state).to eq 'applicant_details_checked'
        end
      end

      context 'provider does not have passported permissions' do
        let(:provider_passported_permission) { false }
        it 'returns true' do
          expect(subject).to be true
        end

        it 'changes the state' do
          subject
          expect(laa.state).to eq 'use_ccms'
        end
      end
    end

    context 'provider does have non-passported permissions' do
      let(:provider_non_passported_permission) { false }

      context 'provider has passported permissions' do
        let(:provider_passported_permission) { true }
        it 'returns false' do
          expect(subject).to be false
        end

        it 'does not change the state' do
          subject
          expect(laa.state).to eq 'applicant_details_checked'
        end
      end

      context 'provider does not have passported permissions' do
        let(:provider_passported_permission) { false }
        it 'returns true' do
          expect(subject).to be true
        end

        it 'changes the state on the application' do
          subject
          expect(laa.state).to eq 'use_ccms'
        end
      end
    end
  end

  context 'applicant does not receive benefit' do
    let(:receives_benefit) { false }
    let(:provider_passported_permission) { true }

    context 'provider has non_passported permissions' do
      let(:provider_non_passported_permission) { true }
      it 'returns false' do
        expect(subject).to be false
      end

      it 'does not change the state' do
        subject
        expect(laa.state).to eq 'applicant_details_checked'
      end
    end

    context 'provider does not have passported permissions' do
      let(:provider_non_passported_permission) { false }
      it 'returns true' do
        expect(subject).to be true
      end

      it 'changes the state on the application' do
        subject
        expect(laa.state).to eq 'use_ccms'
      end
    end
  end
end
