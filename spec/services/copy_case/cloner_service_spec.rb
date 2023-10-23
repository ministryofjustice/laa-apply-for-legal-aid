require "rails_helper"

RSpec.describe CopyCase::ClonerService do
  subject(:instance) { described_class.new(copy, original) }

  describe "#call" do
    subject(:call) { instance.call }

    let(:copy) { create(:legal_aid_application, :with_applicant) }
    let(:original) { create(:legal_aid_application, :with_proceedings) }

    it "copies proceedings" do
      expect { call }
        .to change { copy.reload.proceedings.count }
        .from(0)
        .to(1)

      original_proceeding = original.proceedings.first
      copy_of_proceeding = copy.proceedings.first
      expected_attributes = original_proceeding
                              .attributes
                              .except("id",
                                      "legal_aid_application_id",
                                      "proceeding_case_id",
                                      "created_at",
                                      "updated_at")

      expect(copy_of_proceeding)
        .to have_attributes(**expected_attributes)
    end
  end
end
