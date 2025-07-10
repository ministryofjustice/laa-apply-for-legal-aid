require "rails_helper"

RSpec.describe TaskStatus::DWPOutcome do
  subject(:task_status) { described_class.new(application).call }

  describe "#call" do
    # TODO: add this spec in when check your answers validation is available
    # context "when check_your_answers is not completed" do
    # let(:application) { create(:application) }
    #
    #   it "returns the status of :not_ready" do
    #     expect(task_status.value).to eq(:not_ready)
    #   end
    # end

    context "with `confirm_dwp_result=nil`" do
      let(:application) { create(:application) }

      it "returns the status of :not_started" do
        expect(task_status.value).to eq(:not_started)
      end
    end

    context "with `confirm_dwp_result=false`" do
      let(:application) { create(:application, confirm_dwp_result: false) }

      it "returns the status of :in_progress" do
        expect(task_status.value).to eq(:in_progress)
      end
    end

    context "with `confirm_dwp_result=true`" do
      let(:application) { create(:application, confirm_dwp_result: true) }

      it "returns the status of :completed" do
        expect(task_status.value).to eq(:completed)
      end
    end
  end
end
