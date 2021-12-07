require 'rails_helper'

module HMRC
  RSpec.describe EmploymentIncomeSummary do
    describe '.new' do
      context 'When only one employment' do
        let(:laa) { create :legal_aid_application }

        before { create :hmrc_response, :use_case_one, legal_aid_application_id: laa.id }

        subject { described_class.new(laa.id) }

        it 'creates an array of one Employment object' do
          expect(subject.num_employments).to eq 1
          expect(subject.employments.first.class).to eq Employment
        end
      end
    end
  end
end
