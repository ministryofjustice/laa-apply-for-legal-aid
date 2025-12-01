require "rails_helper"

RSpec.describe CopyCase::ClonerService do
  subject(:instance) { described_class.new(target, source) }

  let(:target) { create(:legal_aid_application, :with_applicant) }
  let(:source) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_everything,
           :with_attempts_to_settle,
           :with_involved_children,
           in_scope_of_laspo: true,
           emergency_cost_override: true,
           emergency_cost_requested: 10_000,
           emergency_cost_reasons: "reason")
  end

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

    it "does not change source proceedings" do
      expect { call }.not_to change { source.reload.proceedings.count }
    end

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

      it "does not change source scope limitations" do
        expect { call }
          .not_to change { source.reload.proceedings.first&.scope_limitations&.count }
          .from(2)
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
      create(:matter_opposition, legal_aid_application: source)
      create(:undertaking, :with_data, legal_aid_application: source)
      create(:urgency, legal_aid_application: source)
      create(:appeal, legal_aid_application: source)

      expect { call }
        .to change { target.reload.allegation }.from(nil)
        .and change { target.reload.domestic_abuse_summary }.from(nil)
        .and change { target.reload.in_scope_of_laspo }.from(nil).to(true)
        .and change { target.reload.involved_children.size }.from(0).to(3)
        .and change { target.reload.latest_incident }.from(nil)
        .and change { target.reload.matter_opposition.present? }.from(false).to(true)
        .and change { target.reload.opponents.size }.from(0).to(1)
        .and change { target.reload.parties_mental_capacity }.from(nil)
        .and change { target.reload.statement_of_case }.from(nil)
        .and change { target.reload.undertaking }.from(nil)
        .and change { target.reload.urgency }.from(nil)
        .and change { target.reload.appeal }.from(nil)
    end

    it "does not change source opponents" do
      expect { call }
        .not_to change { source.reload.opponents.size }.from(1)
    end

    context "when an application with merits is added" do
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

      it "copies proceeding merits attributes successfully" do
        expect { call }
        .to change { target.reload.proceedings.any?(&:attempts_to_settle) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:chances_of_success) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:opponents_application) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:prohibited_steps) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:specific_issue) }.from(false).to(true)
        .and change { target.reload.proceedings.any?(&:vary_order) }.from(false).to(true)
      end
    end

    context "and there are nested linked children merits" do
      let(:source) do
        create(
          :legal_aid_application,
          :with_everything,
          :with_involved_children,
        )
      end
      let(:first_proceeding) { create(:proceeding, :se003, legal_aid_application: source) }
      let(:second_proceeding) { create(:proceeding, :se003, legal_aid_application: source) }
      let(:third_proceeding) { create(:proceeding, :se003, legal_aid_application: source) }
      let(:first_child) { source.involved_children.first }
      let(:second_child) { source.involved_children.second }
      let(:third_child) { source.involved_children.third }

      before do
        create(:proceeding_linked_child, proceeding: first_proceeding, involved_child: first_child)
        create(:proceeding_linked_child, proceeding: second_proceeding, involved_child: second_child)
        create(:proceeding_linked_child, proceeding: third_proceeding, involved_child: third_child)
      end

      it "successfully copies nested linked children merits" do
        expect { call }
          .to change { target.reload.proceedings.first&.proceeding_linked_children&.size }.from(nil).to(1)
          .and change { target.reload.proceedings.second&.proceeding_linked_children&.size }.from(nil).to(1)
          .and change { target.reload.proceedings.third&.proceeding_linked_children&.size }.from(nil).to(1)
          .and change { target.reload.involved_children&.size }.from(0).to(3)
      end

      it "does not change source proceeding linked children" do
        expect { call }
          .not_to change { source.reload.proceedings.first&.proceeding_linked_children&.size }.from(1)
      end

      it "does not change source involved children" do
        expect { call }
          .not_to change { source.reload.involved_children.size }.from(3)
      end
    end

    it "copies legal_framework_merits_task_list" do
      create(:legal_framework_merits_task_list, :da001, legal_aid_application: source)

      expect { call }
        .to change(target, :legal_framework_merits_task_list)
        .from(nil)
        .to(instance_of(LegalFramework::MeritsTaskList))
      expect(target.reload.legal_framework_merits_task_list.serialized_data).to eq(source.reload.legal_framework_merits_task_list.serialized_data)
    end

    context "when cloning proceedings raises an error" do
      before do
        allow(source).to receive(:proceedings).and_raise(StandardError, "new fake error")
      end

      it "sends the error to the rails logs" do
        expect(Rails.logger).to receive(:error).with("clone_proceedings error: new fake error")
        call
      end

      it "sends the error to alert manager" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("clone_proceedings error: new fake error"))
        call
      end

      it "returns false" do
        expect(call).to be false
      end
    end

    context "when cloning application merits raises an error" do
      before do
        allow(source).to receive(:allegation).and_raise(StandardError, "fake error")
      end

      it "returns false" do
        expect(call).to be false
      end
    end

    context "when cloning opponents raises an error" do
      before do
        allow(source).to receive(:opponents).and_raise(StandardError, "fake error")
      end

      it "returns false" do
        expect(call).to be false
      end
    end

    context "when cloning involved_children raises an error" do
      before do
        allow(source).to receive(:involved_children).and_raise(StandardError, "fake error")
      end

      it "returns false" do
        expect(call).to be false
      end
    end

    context "when cloning legal_framework_merits_task_list raises an error" do
      before do
        allow(source).to receive(:legal_framework_merits_task_list).and_raise(StandardError, "fake error")
      end

      it "returns false" do
        expect(call).to be false
      end
    end
  end
end
