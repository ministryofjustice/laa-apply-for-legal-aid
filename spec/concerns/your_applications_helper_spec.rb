require "rails_helper"

RSpec.describe YourApplicationsHelper, type: :controller do
  controller(ApplicationController) do
    include described_class

    def index
      render plain: your_applications_default_tab_path
    end
  end

  it "returns the overview path" do
    get :index
    expect(response.body).to eq(submitted_providers_legal_aid_applications_path)
  end
end
