require "rails_helper"

RSpec.describe Task::MakeLink do
  subject(:instance) { described_class.new(application, name: "make_link") }

  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    include Rails.application.routes.url_helpers

    it "returns the route to first step of the task list item" do
      expect(instance.path).to eql providers_legal_aid_application_link_application_make_link_path(application)
    end
  end
end
