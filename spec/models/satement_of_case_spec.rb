require 'rails_helper'

RSpec.describe StatementOfCase do
  let(:application) { create :legal_aid_application }
  let(:new_soc) { application.build_statement_of_case }

  context 'saving a new record' do
    context 'with a statement' do
      it 'saves ok' do
        new_soc.statement = Faker::Lorem.paragraph(2)
        expect(new_soc.save).to be true
      end
    end

    context 'without a statement' do
      it 'errors' do
        expect(new_soc.save).to be false
        expect(new_soc.errors[:statement]).to eq ['Enter the statement of case']
      end
    end
  end
end
