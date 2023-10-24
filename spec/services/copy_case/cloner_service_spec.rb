require "rails_helper"

RSpec.describe CopyCase::ClonerService do
  subject(:instance) { described_class.new(target, source) }

  describe "#call" do
    subject(:call) { instance.call }

    let(:target) { create(:legal_aid_application, :with_applicant) }
    let(:source) { create(:legal_aid_application, :with_proceedings) }

    it "copies proceedings" do
      expect { call }
        .to change { target.reload.proceedings.count }
        .from(0)
        .to(1)

      source_proceeding = source.proceedings.first
      copy_of_proceeding = target.proceedings.first
      expected_attributes = source_proceeding
                              .attributes
                              .except("id",
                                      "legal_aid_application_id",
                                      "proceeding_case_id",
                                      "created_at",
                                      "updated_at")

      expect(copy_of_proceeding)
        .to have_attributes(**expected_attributes)
    end

    context "when source has a proceeding with nested scope limitations" do
      it "copies proceedings scope limitations" do
        expect { call }
          .to change { target.reload.proceedings.first&.scope_limitations&.count }
          .from(nil)
          .to(2)

        source_scope_limitations = source.proceedings.first.scope_limitations.map do |scl|
          scl.attributes.except("id", "proceeding_id", "created_at", "updated_at")
        end

        target_scope_limitations = target.proceedings.first.scope_limitations.map do |scl|
          scl.attributes.except("id", "proceeding_id", "created_at", "updated_at")
        end

        expect(target_scope_limitations).to match_array(source_scope_limitations)
      end
    end
  end
end
