require "rails_helper"

RSpec.describe TaskStatus::Base do
  subject(:instance) { sub_class.new(application, status_results) }

  let(:sub_class) do
    Class.new(described_class) do
    private

      def perform(status)
        status.not_started!
      end
    end
  end

  let(:application) { create(:application) }
  let(:status_results) { {} }

  describe "#call" do
    subject(:call) { instance.call }

    it "returns a ValueObject" do
      expect(call).to be_a(TaskStatus::ValueObject)
    end

    it "stores the status in the status_results hash" do
      call
      expect(status_results[sub_class])
        .to be_a(TaskStatus::ValueObject)
        .and be_not_started
    end

    context "when perform is not implemented in the subclass" do
      let(:sub_class) { Class.new(described_class) }

      it "raises NotImplementedError" do
        expect { call }.to raise_error(NotImplementedError, "Subclasses of TaskStatus::Base must implement the perform method")
      end
    end

    context "when class relies on previous tasks being completed" do
      let(:sub_class) do
        Class.new(described_class) do
        private

          def perform(status)
            status.not_started! if not_started?
          end

          def not_started?
            previous_tasks_completed?
          end
        end
      end

      it "successfully calls private base methods to return expected status" do
        expect(instance.call).to be_not_started
      end
    end
  end
end
