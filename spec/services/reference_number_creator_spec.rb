require 'rails_helper'

RSpec.describe ReferenceNumberCreator do
  subject { ReferenceNumberCreator.new }

  describe '#call' do
    it 'matches the regex' do
      expect(subject.call).to match(/L(-[ABCDEFHJKLMNPRTUVWXY0-9]{3}){2}/)
    end

    context 'first generated numbers are taken' do
      let(:existing_reference_number) { 'L-AAA-AAA' }
      let(:other_existing_reference_number) { 'L-BBB-BBB' }
      let(:third_reference_number) { 'L-CCC-CCC' }
      let!(:legal_aid_application) { create :legal_aid_application, application_ref: existing_reference_number }
      let!(:other_legal_aid_application) { create :legal_aid_application, application_ref: other_existing_reference_number }

      before do
        allow(subject)
          .to receive(:random_reference_number)
          .and_return(
            existing_reference_number,
            other_existing_reference_number,
            third_reference_number
          )
      end

      it 'generates another number' do
        expect(subject.call).to eq(third_reference_number)
      end
    end
  end
end
