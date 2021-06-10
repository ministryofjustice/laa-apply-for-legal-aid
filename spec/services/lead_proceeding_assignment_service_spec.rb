require 'rails_helper'

RSpec.describe LeadProceedingAssignmentService do
  let(:pt_da1) { create :proceeding_type, :domestic_abuse }
  let(:pt_da2) { create :proceeding_type, :domestic_abuse }
  let(:pt_s81) { create :proceeding_type, :section8 }
  let(:pt_s82) { create :proceeding_type, :section8 }
  let!(:laa) { create :legal_aid_application, :with_proceeding_types, assign_lead_proceeding: false, explicit_proceeding_types: explicit_proceeding_types }

  subject { described_class.call(laa) }

  context 'when a lead proceeding already exists' do
    let(:explicit_proceeding_types) { [pt_s81, pt_s82, pt_da1, pt_da2] }
    before { make_lead!(pt_da2) }

    it 'changes nothing' do
      subject
      expect(apt_for(pt_s81).lead_proceeding?).to be false
      expect(apt_for(pt_s82).lead_proceeding?).to be false
      expect(apt_for(pt_da1).lead_proceeding?).to be false
      expect(apt_for(pt_da2).lead_proceeding?).to be true
    end
  end

  context 'when there are no lead proceedings' do
    let(:explicit_proceeding_types) { [pt_s81, pt_s82, pt_da1] }

    it 'sets the domestic abuse proceeding as lead' do
      subject
      expect(apt_for(pt_s81).lead_proceeding?).to be false
      expect(apt_for(pt_s82).lead_proceeding?).to be false
      expect(apt_for(pt_da1).lead_proceeding?).to be true
    end
  end

  context 'when there are no domestic abuse proceedings' do
    let(:explicit_proceeding_types) { [pt_s81, pt_s82] }

    it 'changes nothing' do
      expect(apt_for(pt_s81).lead_proceeding?).to be false
      expect(apt_for(pt_s82).lead_proceeding?).to be false
    end
  end

  def make_lead!(proceeding_type)
    apt_for(proceeding_type).update!(lead_proceeding: true)
  end

  def apt_for(proceeding_type)
    laa.application_proceeding_types.find_by(proceeding_type_id: proceeding_type.id)
  end
end
