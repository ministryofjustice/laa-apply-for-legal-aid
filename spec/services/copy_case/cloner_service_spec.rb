require "rails_helper"

RSpec.describe CopyCase::ClonerService do
  subject(:instance) { described_class.new(target, source) }

  let(:target) { create(:legal_aid_application, :with_applicant) }
  let(:source) { create(:legal_aid_application, :with_proceedings, :with_everything, :with_involved_children, :with_attempts_to_settle) }

  describe ".call" do
    subject(:call) { described_class.call(target, source) }

    let(:cloner) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(cloner)
      allow(cloner).to receive(:call)
    end

    it "calls self#call" do
      call
      expect(described_class).to have_received(:new).with(target, source)
      expect(cloner).to have_received(:call)
    end
  end

  describe "#call" do
    subject(:call) { instance.call }

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

    context "when target already has proceedings" do
      let(:target) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 da004]) }
      let(:source) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[se014 se013]) }

      before do
        target
        source
      end

      it "copies new proceedings over old" do
        expect { call }
          .to change { target.reload.proceedings.map(&:ccms_code).sort }
          .from(%w[DA001 DA004].sort)
          .to(%w[SE014 SE013].sort)
      end

      it "does not leave any orphan proceedings" do
        expect { call }.not_to change(Proceeding, :count)
      end
    end

    it "copies application merits" do
      create(:allegation, :with_data, legal_aid_application: source)
      create(:undertaking, :with_data, legal_aid_application: source)
      create(:urgency, legal_aid_application: source)

      expect { call }
        .to change { target.reload.allegation }.from(nil)
        .and change { target.reload.domestic_abuse_summary }.from(nil)
        .and change { target.reload.involved_children.size }.from(0).to(3)
        .and change { target.reload.latest_incident }.from(nil)
        .and change { target.reload.opponents.size }.from(0).to(1)
        .and change { target.reload.parties_mental_capacity }.from(nil)
        .and change { target.reload.statement_of_case }.from(nil)
        .and change { target.reload.undertaking }.from(nil)
        .and change { target.reload.urgency }.from(nil)
    end

    context "when an application with every possible merit is added" do
      let(:source) do
        create(
          :legal_aid_application,
          :with_proceedings,
          :with_everything,
          :with_involved_children,
          :with_attempts_to_settle,
          :with_chances_of_success,
          :with_opponents_application_proceeding,
          :with_prohibited_steps,
          :with_specific_issue,
          :with_vary_order,
        )
      end

      it "copies proceeding merits successfully" do
        expect { call }
        .to change { target.reload.proceedings.any?(&:attempts_to_settle) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:chances_of_success) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:opponents_application) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:prohibited_steps) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:specific_issue) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:vary_order) }.from(false).to(true)
        # .and change { target.reload.proceedings.any?(&.proceeding_linked_children:)&.size }.from(0).to(1)
      end
    end
  end
end
