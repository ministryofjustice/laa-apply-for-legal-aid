require "rails_helper"

RSpec.describe Task::ProceedingsTypes do
  subject(:instance) { described_class.new(application, name: "proceedings_types") }

  describe "#path" do
    include Rails.application.routes.url_helpers

    context "when there are no proceedings selected" do
      let(:application) { create(:legal_aid_application) }

      it "returns the route to first step of the task list item" do
        expect(instance.path).to eql providers_legal_aid_application_proceedings_types_path(application)
      end
    end

    context "when one or more proceedings are selected" do
      let(:application) { create(:legal_aid_application, :with_proceedings) }

      it "returns the route to first step of the task list item" do
        expect(instance.path).to eql providers_legal_aid_application_has_other_proceedings_path(application)
      end
    end
  end
end
