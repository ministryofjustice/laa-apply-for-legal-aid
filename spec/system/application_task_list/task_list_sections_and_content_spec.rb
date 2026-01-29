require "system_helper"

RSpec.describe "Application task list page sections, subsections and content", :vcr do
  feature "View the application task list" do
    before do
      login_as_a_provider
    end

    let(:applicant) do
      build(:applicant,
            first_name: "John",
            last_name: "Doe",
            date_of_birth: 21.years.ago,
            has_national_insurance_number: nil,
            national_insurance_number: nil)
    end

    context "with an application completed as far as national insurance numnber" do
      let(:application) do
        create(
          :application,
          provider_step: "has_national_insurance_numbers",
          provider: @registered_provider,
          applicant:,
        )
      end

      scenario "I can view the application task list's basic information" do
        visit providers_legal_aid_application_task_list_path(application)

        expect(page)
          .to have_css("h1", text: "Make a new application")
          .and have_css(".govuk-body", text: "Use this list to see your progress")
          .and have_css(".govuk-body", text: "You can go back and edit completed sections if they appear as links. More sections will become editable over time.")
          .and have_css(".govuk-body", text: "Name: John Doe")
          .and have_css(".govuk-body", text: /Reference number: L-\w{3}-\w{3}/)
      end

      scenario "I can view the application task list in it's initial state" do
        visit providers_legal_aid_application_task_list_path(application)

        expect(page)
          .to have_css("h2.govuk-task-list__section", text: "1. Client and case details")
          .and have_css("h2.govuk-task-list__section", text: "2. Means test")
          .and have_content("We may ask you later about your client's income, outgoings, savings, investments, assets, payments and dependants, if it's needed")
          .and have_css("h2.govuk-task-list__section", text: "3. Merits")
          .and have_content("Once the proceedings have been selected, the relevant tasks will appear in this section.")
          .and have_css("h2.govuk-task-list__section", text: "4. Confirm and submit")
      end
    end

    context "with a passported application" do
      let(:application) do
        app = create(:application, :with_proceedings, provider: @registered_provider, applicant:)
        create(:benefit_check_result, :positive, legal_aid_application: app)
        app
      end

      scenario "I can view the application task list in it's passported state" do
        visit providers_legal_aid_application_task_list_path(application)

        expect(page)
          .to have_css("h3.govuk-task-list__section", text: "Financial information")
          .and have_content("You do not need to give financial information because DWP records show that your client gets a passporting benefit.")
          .and have_css("h3.govuk-task-list__section", text: "Capital and assets")
          .and have_css("h3.govuk-task-list__section", text: "About this application")
          .and have_css("h3.govuk-task-list__section", text: "About the proceedings")
          .and have_css("h3.govuk-task-list__section", text: "Supporting evidence and review")
      end
    end

    context "with a non-passported application" do
      let(:application) do
        app = create(:legal_aid_application, :with_proceedings, provider: @registered_provider, applicant:)
        create(:benefit_check_result, :negative, legal_aid_application: app)
        app
      end

      scenario "I can view the application task list in it's non-passported state" do
        visit providers_legal_aid_application_task_list_path(application)

        expect(page)
          .to have_css("h3.govuk-task-list__section", text: "Financial information")
          .and have_css("h3.govuk-task-list__section", text: "Capital and assets")
          .and have_css("h3.govuk-task-list__section", text: "About this application")
          .and have_css("h3.govuk-task-list__section", text: "About the proceedings")
          .and have_css("h3.govuk-task-list__section", text: "Supporting evidence and review")
          .and have_no_content("You do not need to give financial information because")
      end
    end

    context "with a non-means-tested application" do
      let(:application) do
        app = create(
          :legal_aid_application,
          :with_proceedings,
          :with_under_18_applicant,
          provider: @registered_provider,
        )

        create(:benefit_check_result, :negative, legal_aid_application: app)
        app
      end

      scenario "I can view the application task list in it's non-means-tested state" do
        visit providers_legal_aid_application_task_list_path(application)

        expect(page)
          .to have_content("We may ask you later about your client's income, outgoings, savings, investments, assets, payments and dependants, if it's needed")
          .and have_css("h3.govuk-task-list__section", text: "About this application")
          .and have_css("h3.govuk-task-list__section", text: "About the proceedings")
          .and have_css("h3.govuk-task-list__section", text: "Supporting evidence and review")
          .and have_no_content("Financial information")
          .and have_no_content("Capital and assets")
      end
    end
  end
end
