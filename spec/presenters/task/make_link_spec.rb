require "rails_helper"

RSpec.describe Task::MakeLink do
  subject(:instance) { described_class.new(application, name: "make_link") }

  let(:application) { create(:legal_aid_application) }
  let(:lead_linked_application) { nil }

  before { application.update!(lead_linked_application:) }

  describe "#path" do
    include Rails.application.routes.url_helpers

    context "when there is no lead linked application" do
      it "returns the route to first step of the task list item" do
        expect(instance.path).to eql providers_legal_aid_application_link_application_make_link_path(application)
      end
    end

    context "when there is a lead linked application" do
      let(:lead_linked_application) do
        create(:linked_application,
               link_type_code:,
               confirm_link:,
               associated_application_id: application.id,
               lead_application_id:)
      end
      let(:lead_application_id) { nil }
      let(:confirm_link) { nil }
      let(:link_type_code) { nil }

      context "when the provider has not selected an application to link to" do
        it "returns the route to first step of the task list item" do
          expect(instance.path).to eql providers_legal_aid_application_link_application_find_link_application_path(application)
        end
      end

      context "when the provider has not confirmed the link" do
        let(:lead_application) { create(:legal_aid_application) }
        let(:lead_application_id) { lead_application.id }

        it "returns the route to first step of the task list item" do
          expect(instance.path).to eql providers_legal_aid_application_link_application_confirm_link_path(application)
        end
      end

      context "when the link has been confirmed and family linking" do
        let(:lead_application) { create(:legal_aid_application) }
        let(:lead_application_id) { lead_application.id }
        let(:confirm_link) { true }
        let(:link_type_code) { "FC_LEAD" }

        it "returns the route to first step of the task list item" do
          expect(instance.path).to eql providers_legal_aid_application_link_application_copy_path(application)
        end
      end
    end
  end
end
