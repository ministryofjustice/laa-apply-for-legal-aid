require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::MakeLink do
  subject(:validator) { described_class.new(application) }
  
  let(:complete_linked_application) do
    create(:linked_application,
            associated_application:,
            link_type_code:,
            confirm_link:)
  end
  
  let(:associated_application) { create(:legal_aid_application) }
  let(:application) { create(:application, lead_linked_application:) }
  let(:lead_linked_application) { complete_linked_application }
  let(:link_type_code) { nil }
  let(:confirm_link) { nil }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when linking is not required" do
      let(:link_type_code) { "false" }
      let(:confirm_link) { nil }

      it { is_expected.to be_valid }
    end
  
    context "when link is legal" do
      context "when link is not confirmed" do
        let(:link_type_code) { "LEGAL" }
        let(:confirm_link) { "false" }

        it { is_expected.to be_valid }
      end

      context "with all relevant answers completed" do
        let(:link_type_code) { "LEGAL" }
        let(:confirm_link) { "true" }

        it { is_expected.to be_valid }
      end

      context "without all relevant answers completed" do
        let(:link_type_code) { "LEGAL" }
        let(:confirm_link) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    context "when link is family" do
      context "when link is not confirmed" do
        let(:link_type_code) { "FC_LEAD" }
        let(:confirm_link) { "false" }

        it { is_expected.to be_valid }
      end

      xcontext "with all relevant answers completed" do
        let(:link_type_code) { "FC_LEAD" }
        let(:confirm_link) { "true" }

        it { is_expected.to be_valid }
      end

      context "without all relevant answers completed" do
        context "when link not confirmed" do
          let(:link_type_code) { "FC_LEAD" }
          let(:confirm_link) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when copy not completed" do
          let(:link_type_code) { "FC_LEAD" }
          let(:target_application_id) { nil }
          let(:confirm_link) { "true" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
