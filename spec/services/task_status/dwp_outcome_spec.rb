require "rails_helper"

RSpec.describe TaskStatus::DWPOutcome do
  describe "#call" do
    subject(:task_status) { described_class.new(application).call }

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

      it { is_expected.to be_not_started }
    end

    context "with `confirm_dwp_result=false`" do
      let(:application) { create(:application, confirm_dwp_result: false) }

      it { is_expected.to be_in_progress }
    end

    context "with `confirm_dwp_result=true`" do
      let(:application) { create(:application, confirm_dwp_result: true) }

      it { is_expected.to be_completed }
    end
  end
end
