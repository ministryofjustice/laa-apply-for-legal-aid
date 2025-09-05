require "rails_helper"

RSpec.describe ProvidersHelper do
  let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
  let(:provider_routes) do
    Rails.application.routes.routes.select do |route|
      route.defaults[:controller].to_s.split("/")[0] == "providers" &&
        route.parts.include?(:legal_aid_application_id)
    end
  end
  let(:provider_controller_names) do
    provider_routes.map { |route|
      route.defaults[:controller].to_s.split("/")[1]
    }.uniq
  end
  let(:controllers_with_params) { %w[incoming_transactions outgoing_transactions remove_dependants] }
  let(:excluded_controllers) { %w[bank_transactions] + controllers_with_params }
  let(:home_address_controllers) do
    %w[home_addresses
       home_address_lookups
       home_address_selections
       different_addresses
       non_uk_home_addresses]
  end

  describe "#tag_colour" do
    subject(:url_helper) { tag_colour(legal_aid_application) }

    context "when the application has `expired`" do
      let(:legal_aid_application) do
        travel_to Date.parse("2023-12-25") do
          create(:legal_aid_application, :with_multiple_proceedings_inc_section8, provider_step: "chances_of_success")
        end
      end

      it { is_expected.to eql("red") }
    end

    context "when the application is submitted" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_merits_submitted_at) }

      it { is_expected.to eql("green") }
    end

    context "when the application is not submitted" do
      it { is_expected.to eql("blue") }
    end
  end

  describe "#url_for_application" do
    subject(:url_helper) { url_for_application(legal_aid_application) }

    it "does not crash" do
      (provider_controller_names - excluded_controllers + home_address_controllers).each do |controller_name|
        legal_aid_application.provider_step = controller_name
        expect { url_for_application(legal_aid_application) }.not_to raise_error
      end
    end

    it "incoming_transactions should return the right URL with param" do
      legal_aid_application.provider_step = "incoming_transactions"
      legal_aid_application.provider_step_params = { transaction_type: :pension }
      expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/incoming_transactions/pension?locale=en")
    end

    it "outgoing_transactions should return the right URL with param" do
      legal_aid_application.provider_step = "outgoing_transactions"
      legal_aid_application.provider_step_params = { transaction_type: :pension }
      expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/outgoing_transactions/pension?locale=en")
    end

    context "when saved as draft and amending involved child" do
      it do
        legal_aid_application.provider_step = "involved_children"
        legal_aid_application.provider_step_params = { id: "21983d92-876d-4f95-84df-1af2e3308fd7" }
        expect(url_helper).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/21983d92-876d-4f95-84df-1af2e3308fd7?locale=en")
      end
    end

    context "when saved as draft and returning to a started involved child" do
      let(:partial_record) { create(:involved_child, legal_aid_application:, date_of_birth: nil) }

      it do
        legal_aid_application.provider_step = "involved_children"
        legal_aid_application.provider_step_params = { application_merits_task_involved_child: { full_name: partial_record.full_name }, id: "new" }
        expect(url_helper).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/#{partial_record.id}?locale=en")
      end
    end

    context "when saved as draft and adding a new involved child" do
      it do
        legal_aid_application.provider_step = "involved_children"
        legal_aid_application.provider_step_params = { application_merits_task_involved_child: { full_name: nil }, id: "new" }
        expect(url_helper).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/new?locale=en")
      end
    end

    context "when saved as draft and linking children" do
      it do
        legal_aid_application.provider_step = "linked_children"
        lead_proceeding = legal_aid_application.proceedings.find_by(lead_proceeding: true)
        legal_aid_application.provider_step_params = { merits_task_list_id: lead_proceeding.id }
        expect(url_helper).to eq("/providers/merits_task_list/#{lead_proceeding.id}/linked_children?locale=en")
      end
    end

    context "when saved as draft and returning to date_client_told_incident" do
      it do
        legal_aid_application.provider_step = "date_client_told_incidents"
        legal_aid_application.provider_step_params = { application_merits_task_incident: { told_on_3i: "",
                                                                                           told_on_2i: "",
                                                                                           told_on_1i: "",
                                                                                           occurred_on_3i: "",
                                                                                           occurred_on_2i: "",
                                                                                           occurred_on_1i: "" } }
        expect(url_helper).to eq("/providers/applications/#{legal_aid_application.id}/date_client_told_incident?locale=en")
      end
    end

    context "when saved as draft and returning to chances_of_success" do
      it do
        legal_aid_application.provider_step = "chances_of_success"
        lead_proceeding = legal_aid_application.proceedings.find_by(lead_proceeding: true)
        legal_aid_application.provider_step_params = { merits_task_list_id: lead_proceeding.id }
        expect(url_helper).to eq("/providers/merits_task_list/#{lead_proceeding.id}/chances_of_success?locale=en")
      end
    end

    context "when removing a dependant" do
      let(:dependant) { create(:dependant, legal_aid_application:) }

      it "routes correctly" do
        legal_aid_application.provider_step = "remove_dependants"
        legal_aid_application.provider_step_params = { id: dependant.id }
        expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/means/remove_dependants/#{dependant.id}?locale=en")
      end
    end

    context "when the application predates the 2025 incident" do
      let(:legal_aid_application) do
        travel_to Date.parse("2025-7-31") do
          create(:legal_aid_application, :with_multiple_proceedings_inc_section8, provider_step:)
        end
      end

      context "and the provider step is not in the list of blocked or completed steps" do
        let(:provider_step) { "chances_of_success" }

        it "routes to the block page" do
          application_id = legal_aid_application.id
          expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{application_id}/voided-application?locale=en")
        end
      end

      context "and the provider step is in the list of blocked or completed steps" do
        let(:provider_step) { "submitted_applications" }

        it "routes to the submitted application page" do
          application_id = legal_aid_application.id
          expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{application_id}/submitted_application?locale=en")
        end
      end
    end
  end
end
