require "rails_helper"

module LegalFramework
  RSpec.describe SerializableMeritsTaskList do
    before do
      create(:proceeding, :da004)
      create(:proceeding, :da001)
    end

    let(:smtl) { described_class.new(dummy_response_hash) }

    describe ".new" do
      it "instantiates a new object" do
        expect(smtl.tasks[:application].map(&:name)).to eq %i[incident_details opponent_details application_children]
      end
    end

    describe "serialization" do
      it "can serialize and deserialize" do
        serialized_string = smtl.to_yaml
        new_smtl = described_class.new_from_serialized(serialized_string)
        expect(new_smtl.tasks[:application].map(&:name)).to eq %i[incident_details opponent_details application_children]
      end
    end

    describe "#tasks_for" do
      context "with application group" do
        it "returns an array of serializable merits tasks" do
          tasks = smtl.tasks_for(:application)
          expect(tasks.size).to eq 3
          expect(tasks.map(&:class).uniq).to eq [SerializableMeritsTask]
          expect(tasks.map(&:name)).to eq %i[incident_details opponent_details application_children]
        end
      end

      context "with ccms_code" do
        it "returns an array of serializable merits tasks" do
          tasks = smtl.tasks_for(:DA004)
          expect(tasks.size).to eq 1
          expect(tasks.map(&:class).uniq).to eq [SerializableMeritsTask]
          expect(tasks.map(&:name)).to eq %i[chances_of_success]
        end
      end

      context "with invalid_task_group" do
        it "raises an exception" do
          expect { smtl.tasks_for(:XX001) }.to raise_error KeyError, "key not found: :XX001"
        end
      end
    end

    describe "#mark_as_complete!" do
      context "with invalid task name" do
        it "raises an exception" do
          expect {
            smtl.mark_as_complete!(:application, :rubbish)
          }.to raise_error KeyError, "key not found: :rubbish"
        end
      end

      context "with invalid task group name" do
        it "raises an exception" do
          expect {
            smtl.mark_as_complete!(:fake, :incident_details)
          }.to raise_error KeyError, "key not found: :fake"
        end
      end

      context "when task has dependencies" do
        it "raises an exception" do
          expect {
            smtl.mark_as_complete!(:DA001, :proceeding_children)
          }.to raise_error RuntimeError, "Unmet dependency application_children for task proceeding_children"
        end
      end

      context "when successful" do
        context "with application group" do
          it "marks the task as complete" do
            smtl.mark_as_complete!(:application, :incident_details)
            expect(smtl.task(:application, :incident_details).state).to eq :complete
          end

          it "marks the dependant tasks as not_started" do
            smtl.mark_as_complete!(:application, :application_children)
            expect(smtl.task(:application, :application_children).state).to eq :complete
            expect(smtl.task(:DA001, :proceeding_children).state).to eq :not_started
          end
        end

        context "with proceeding type" do
          it "marks the task as complete" do
            smtl.mark_as_complete!(:DA004, :chances_of_success)
            expect(smtl.task(:DA004, :chances_of_success).state).to eq :complete
          end
        end
      end
    end

    describe "#mark_as_not_started!" do
      context "with invalid task name" do
        it "raises an exception" do
          expect {
            smtl.mark_as_not_started!(:application, :rubbish)
          }.to raise_error KeyError, "key not found: :rubbish"
        end
      end

      context "with invalid task group name" do
        it "raises an exception" do
          expect {
            smtl.mark_as_not_started!(:fake, :incident_details)
          }.to raise_error KeyError, "key not found: :fake"
        end
      end

      context "when successful" do
        context "with application group" do
          before { smtl.mark_as_complete!(:application, :incident_details) }

          it "marks the task as not started" do
            smtl.mark_as_not_started!(:application, :incident_details)
            expect(smtl.task(:application, :incident_details).state).to eq :not_started
          end
        end

        context "with proceeding type" do
          before { smtl.mark_as_complete!(:DA004, :chances_of_success) }

          it "marks the task as not started" do
            smtl.mark_as_not_started!(:DA004, :chances_of_success)
            expect(smtl.task(:DA004, :chances_of_success).state).to eq :not_started
          end
        end
      end
    end

    def dummy_response_hash
      {
        request_id: SecureRandom.uuid,
        application: {
          tasks: {
            incident_details: [],
            opponent_details: [],
            application_children: [],
          },
        },
        proceedings: [
          {
            ccms_code: "DA004",
            tasks: {
              chances_of_success: [],
            },
          },
          {
            ccms_code: "DA001",
            tasks: {
              chances_of_success: [],
              proceeding_children: [:application_children],
            },
          },
        ],
      }
    end
  end
end
