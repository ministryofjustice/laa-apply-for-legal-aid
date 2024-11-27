require "rails_helper"

RSpec.describe "portal:new_users", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["portal:new_users"].reenable
  end

  describe "portal:new_users" do
    subject(:task) { Rake::Task["portal:new_users"] }

    context "when called with no names" do
      let(:names) { nil }
      let(:expected_output) { "call with rake:portal:new_users[pipe|separated|list|of|names]" }

      it "outputs an error" do
        expect(Rails.logger).to receive(:info).with("call with rake:portal:new_users[pipe|separated|list|of|names]").once
        task.invoke
      end
    end

    context "when called with a non-matching names" do
      let(:name) { "non-matching-name" }
      let(:expected_output) { "NON-MATCHING-NAME bad" }

      before do
        stub_request(:get, /provider-users/)
        .to_return(status: 204)
      end

      it "outputs an error" do
        expect(Rails.logger).to receive(:info).with("NON-MATCHING-NAME bad").once
        expect(Rails.logger).to receive(:info).with("Could not match the following").once
        expect(Rails.logger).to receive(:info).with(%w[NON-MATCHING-NAME]).once
        expect(Rails.logger).to receive(:info).with("No names matched, unable to output ldif file").once
        task.invoke(name)
      end
    end

    context "when called with a matching names" do
      let(:name) { "matching-name" }
      let(:expected_output) { "MATCHING-NAME okay" }

      before do
        stub_request(:get, /provider-users/)
          .to_return(status: 200)
      end

      it "outputs that a match was found" do
        expect(Rails.logger).to receive(:info).with("MATCHING-NAME okay").once
        expect(Rails.logger).to receive(:info).with("Could not match the following").once
        expect(Rails.logger).to receive(:info).with(nil).once
        expect(Rails.logger).to receive(:info).with("Saved file as #{Rails.root.join('tmp/output.ldif')}").once
        task.invoke(name)
      end
    end
  end
end
