require 'rails_helper'

RSpec.describe LegalAidApplications::SubstantiveApplicationForm, type: :form do
  let(:application) { create :legal_aid_application }
  let(:substantive_application) { true }
  let(:params) do
    {
      substantive_application: substantive_application.to_s,
      model: application
    }
  end

  subject { described_class.new(params) }

  describe '#save' do
    it 'updates application' do
      expect { subject.save }
        .to change { application.substantive_application }
        .from(nil)
        .to(substantive_application)
    end

    xit 'generates a deadline date' do
      subject.save
      expect(application.substantive_application_deadline_on).to eq()
    end
  end
end
